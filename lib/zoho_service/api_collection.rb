require 'httparty'
require 'ostruct'
require 'forwardable'

module ZohoService
  class ApiCollection < Array
    attr_reader :parent, :request_params, :loaded

    def initialize(parent, attrs = {})
      @loaded = false
      @parent = parent
      @request_params = attrs
      super()
    end

    def run_request(eval_method)
      return if @loaded
      @loaded = true
      items_class = ZohoService::const_get(request_params[:items_class])
      parent.connector.load_by_api(parent.resource_path + items_class.class_path)&.each do |item_data|
        self << items_class.new(parent, item_data )
      end
    end
  end

  redefine_methods = Array.instance_methods(false) - %i[inspect push] - ApiCollection.instance_methods(false)
  redefine_methods.sort.each do |method|
    ApiCollection.send(:define_method, method ) { |*args, &block| run_request(__method__); super(*args, &block) }
  end
end
