require 'httparty'
require 'forwardable'

module ZohoService
  class ApiConnector < Base
    attr_reader :token, :invalid_token, :client_params, :debug
    def initialize(token_in = nil, client_params_in = {}, debug_in = false)
      raise('Need zoho API token in params for ZohoService::ApiConnector.new') unless token_in
      @token = token_in
      @debug = debug_in
      @client_params = client_params_in
      super()
      @client_params[:api_url] = 'https://desk.zoho.com/api/v1'.freeze unless @client_params[:api_url]
      @client_params[:orgId] = organizations.first&.id unless @client_params[:orgId]
      @client_params[:departmentId] = departments.first&.id unless @client_params[:departmentId]
      @client_params[:timeout] = @client_params[:timeout] ? @client_params[:timeout].to_i : 5
    end

    def resource_path
      @client_params[:api_url]
    end

    def get_headers(params = {})
      client_headers = { 'Authorization': 'Zoho-authtoken  ' + @token }
      client_headers[:orgId] = @client_params[:orgId].to_s if @client_params[:orgId]
      self.class.headers.merge(client_headers)
    end

    def load_by_api(url, query = nil, params = {})
      url = resource_path + '/search' if query && query[:searchStr]
      url = URI.encode(url)
      raise "Invalid CRMCSRFToken. Check your token in ApiConnector in ZohoService gem!\n" if @invalid_token

      request_params = { headers: get_headers(params), timeout: @client_params[:timeout], no_follow: true, limit: 1,
                         follow_redirects: false, read_timeout: @client_params[:timeout] }
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
        if response.code == 200 && !response['message']
          return response['data'] ? response['data'] : response
        elsif response.code == 204 # 204 - no content found or from-limit out of range
          return []
        elsif response.code == 400 # 400 - Invalid CRMCSRFToken
          invalid_CRMCSRFToken()
        else
          invalid_CRMCSRFToken() if response.body&.include?('Invalid CRMCSRFToken')
        end
      end
      bad_response(response, url, query, get_headers(params), params)
      nil
    end

    def invalid_CRMCSRFToken
      @invalid_token = true
      raise('Invalid CRMCSRFToken. Check your token in ApiConnector in ZohoService gem!')
    end

    def bad_response(response, url, query, headers, params)
      error_str = "ZohoService API bad_response url=[#{url}], query=[#{query&.to_json}]\nparams=[#{params.to_json}]\n"
      error_str += response ? "code=[#{response.code}] body=[#{response.body}]\n" : "Unknown error in load_by_api.\n"
      raise error_str
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
