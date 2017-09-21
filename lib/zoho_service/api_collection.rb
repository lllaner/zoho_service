module ZohoService
  class ApiCollection < Array
    attr_reader :parent, :request_params, :loaded

    def initialize(parent, attrs = {})
      @loaded = false
      @parent = parent
      @request_params = attrs # request_params writing only in init proc!
      super()
    end

    def run_request(eval_method)
      return if @loaded
      @loaded = true
      parent.connector.load_by_api(collection_url)&.each do |item_data|
        self.push(request_params[:items_class].new(parent, item_data))
      end
    end

    def new(item_params)
      request_params[:items_class].new(parent, item_params)
    end

    def create(item_params)
      new(item_params).save!
    end

    def collection_url
      parent.resource_path + request_params[:items_class].class_path
    end
  end

  redefine_methods = Array.instance_methods(false) - %i[inspect push] - ApiCollection.instance_methods(false)
  redefine_methods.sort.each do |method|
    ApiCollection.send(:define_method, method ) { |*args, &block| run_request(__method__); super(*args, &block) }
  end
end
