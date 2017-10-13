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
      @client_params[:api_url] = 'http://desk.zoho.com/api/v1'.freeze unless @client_params[:api_url]
      @client_params[:orgId] = organizations.first&.id unless @client_params[:orgId]
      @client_params[:departmentId] = departments.first&.id unless @client_params[:departmentId]
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
      if @invalid_token
        $stderr.puts "Invalid CRMCSRFToken. Check your token in ApiConnector in ZohoService gem!\n" if @debug
        return nil
      end
      request_params = { headers: get_headers(params) }
      if params[:method] == :post
        response = HTTParty.post(url, request_params.merge(body: query.to_json))
      elsif params[:method] == :patch
        response = HTTParty.patch(url, request_params.merge(body: query.to_json))
      elsif params[:method] == :delete
        response = HTTParty.delete(url, request_params)
      else
        url = url + '?' + query.to_query if query
        response = HTTParty.get(url, request_params)
      end
      if response && (response.code == 200 || response['message'])
        $stderr.puts "#{params[:method]} url=[#{url}] length=[#{response.to_json.length}] cnt=[#{response['data']&.count}]\n" if @debug
        return response['data'] ? response['data'] : response
      elsif response && response.code == 204 # 204 - no content found or from-limit out of range
        return []
      end
      bad_response(response, url, query, get_headers(params), params)
      nil
    end

    def bad_response(response, url, query, headers, params)
      $stderr.puts "ZohoService API bad_response url=[#{url}], query=[#{query&.to_json}] \n params=[#{params.to_json}]\n"
      $stderr.puts(response ? "code=[#{response.code}] body=[#{response.body}]\n" : "Unknown error in load_by_api.\n")
      @invalid_token = true if response && response.code == 400 && response.body&.include?('Invalid CRMCSRFToken')
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
