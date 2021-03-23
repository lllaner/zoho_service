require 'httparty'
require 'forwardable'
require 'oauth2'

module ZohoService
  class ApiConnector < Base
    DEFAULT_SCOPES = %w[Desk.tickets.ALL
                        Desk.tasks.ALL
                        Desk.contacts.ALL
                        Desk.basic.ALL
                        Desk.settings.ALL
                        Desk.search.READ
                        Desk.events.ALL
                        Desk.articles.ALL].freeze

    attr_reader :token, :invalid_token, :client_params, :debug, :api_endpoint, :client_id, :client_secret, :redirect_uri
    def initialize(client_params_in = {}, debug_in = false)
      @debug = debug_in
      @client_params = client_params_in
      super()
      @api_endpoint  = @client_params[:api_endpoint]
      @client_id     = @client_params[:client_id]
      @client_secret = @client_params[:client_secret]
      @redirect_uri  = @client_params[:redirect_uri]
      @access_token  = @client_params[:access_token]
      @client_params[:api_url] = 'https://desk.zoho.com/api/v1'.freeze unless @client_params[:api_url]
      @client_params[:orgId] = organizations.first&.id unless @client_params[:orgId]
      @client_params[:departmentId] = departments.first&.id unless @client_params[:departmentId]
      @client_params[:timeout] = @client_params[:timeout] ? @client_params[:timeout].to_i : 5
    end

    def resource_path
      @client_params[:api_url]
    end

    def get_headers(params = {})
      client_headers = { 'Authorization': 'Zoho-oauthtoken  ' + @access_token }
      client_headers[:orgId] = @client_params[:orgId].to_s if @client_params[:orgId]
      self.class.headers.merge(client_headers)
    end

    def load_by_api(url, query = nil, params = {})
      url = resource_path + '/search' if query && query[:searchStr]
      url = URI.encode(url)
      raise "Invalid CRMCSRFToken. Check your token in ApiConnector in ZohoService gem!\n" if @invalid_token

      request_params = { headers: get_headers(params), timeout: @client_params[:timeout], no_follow: true, limit: 1,
                         follow_redirects: false, read_timeout: @client_params[:timeout] }
      response = nil
      begin
        response = if params[:method] == :post
                      HTTParty.post(url, request_params.merge(body: query.to_json))
                    elsif params[:method] == :patch
                      HTTParty.patch(url, request_params.merge(body: query.to_json))
                    elsif params[:method] == :delete
                      HTTParty.delete(url, request_params)
                    else
                      url = url + '?' + query.to_query if query
                      HTTParty.get(url, request_params)
                    end
      rescue HTTParty::RedirectionTooDeep => e
        raise("Can`t Connect to zohoDesk server. RedirectionTooDeep. Check https or maybe your account blocked.\nurl=[#{url}]\nerror=[#{e}]")
      rescue => e
        raise("Can`t Connect to zohoDesk server. Unknown error. Maybe your account blocked.\nurl=[#{url}]\nerror=[#{e}]")
      end
      if response
        $stderr.puts "#{params[:method]} url=[#{url}] length=[#{response.to_json.length}] cnt=[#{response['data']&.count}]\n" if @debug
        if response.code == 200
          raise "Error message in ZohoService gem: \n[#{ response['message'] }]\n" if response['message']
          return response['data'] ? response['data'] : response
        elsif response.code == 204 # 204 - no content found or from-limit out of range
          return []
        else
          invalid_CRMCSRFToken(response)
        end
      end
      bad_response(response, url, query, get_headers(params), params)
      nil
    end

    def invalid_CRMCSRFToken(response)
      @invalid_token = true
      message = 'Response body: '
      message.concat response.body
      message.concat '. Status: '
      message.concat response.code
      raise(message)
    end

    def bad_response(response, url, query, headers, params)
      error_str = "ZohoService API bad_response url=[#{url}], query=[#{query&.to_json}]\nparams=[#{params.to_json}]\n"
      error_str += response ? "code=[#{response.code}] body=[#{response.body}]\n" : "Unknown error in load_by_api.\n"
      raise error_str
    end

    def oauth2client
      @_oauth2client ||=
        OAuth2::Client.new(
          client_id,
          client_secret,
          site: api_endpoint,
          authorize_url: '/oauth/v2/auth',
          token_url: '/oauth/v2/token'
        )
    end

    def authorize_url
      return nil unless oauth2client

      oauth2client.auth_code.authorize_url(
        redirect_uri: redirect_uri,
        scope: DEFAULT_SCOPES.join(','),
        access_type: 'offline'
      )
    end

    def fetch_access_token(code)
      return unless oauth2client
      @_oauth2client.site = api_endpoint

      token = oauth2client.auth_code.get_token(code, redirect_uri: redirect_uri)
      token.params.merge(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at,
        expires_in: token.expires_in
      )
    rescue OAuth2::Error => e
      puts e #FIXME if ::Amorail.debug
    end

    def fetch_refresh_token(refresh_token)
      return unless oauth2client
      @_oauth2client.site = api_endpoint

      token = oauth2client.get_token(
        refresh_token: refresh_token,
        grant_type: 'refresh_token'
      )
      token.params.merge(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at
      )
    rescue OAuth2::Error => e
      puts e #FIXME if  ::Amorail.debug
    end

    class << self
      def headers
        { 'User-Agent'    => 'ZohoService-Ruby-On-Rails-gem-by-chaky222/' + ZohoService::VERSION,
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/x-www-form-urlencoded',
          'Accept-Charset'=> 'UTF-8' }.freeze
      end
    end
  end
end
