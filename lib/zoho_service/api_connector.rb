module ZohoService
  class ApiConnector < Base
    attr_reader :token, :client_params, :debug
    def initialize(token_in = nil, client_params_in = {}, debug_in = false)
      raise('Need zoho API token in params for ZohoService::ApiConnector.new') unless token_in
      @token = token_in
      @debug = debug_in
      @client_params = client_params_in
      super()
      @client_params[:orgId] = organizations.first.id unless @client_params[:orgId]
    end

    def get_headers(params = {})
      client_headers = { 'Authorization': 'Zoho-authtoken  ' + @token }
      client_headers[:orgId] = @client_params[:orgId] if @client_params[:orgId] && !params[:skip_orgId]
      self.class.headers.merge(client_headers)
    end

    def load_by_api(url, query = {}, params = {})
      url = URI.encode('https://desk.zoho.com/api/v1' + url)
      response = HTTParty.get(url, { headers: get_headers(params) })
      if response && response.code == 200
        $stderr.puts "url=[#{url}] length=[#{response.to_json.length}] cnt=[#{response['data']&.count}]\n" if @debug
        return response['data'] ? response['data'] : response
      end
      bad_response(response, url, query, get_headers(params), params)
      nil
    end

    def bad_response(response, url, query, headers, params)
      $stderr.puts "ZohoService API bad_response url=[#{url}], query=[#{query.to_json}]\n"
      $stderr.puts(response ? "code=[#{response.code}] body=[#{response.body}]\n" : "Unknown error in load_by_api.\n")
    end

    class << self
      def headers
        { 'User-Agent'    => 'ZohoProjects-Ruby-Wrappers/0.0.7',
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/x-www-form-urlencoded',
          'Accept-Charset'=> 'UTF-8' }.freeze
      end
    end
  end
end
