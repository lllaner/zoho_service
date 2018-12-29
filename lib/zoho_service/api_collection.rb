module ZohoService
  class ApiCollection < Array
    attr_reader :parent, :request_params, :loaded

    def initialize(parent, attrs = {})
      @loaded = false
      @parent = parent
      @request_params = attrs # request_params writing only in init proc!
      super()
      if accepted_queries.include?('departmentId')
        @request_params[:query] ||= {}
        @request_params[:query][:departmentId] ||= parent.connector.client_params[:departmentId]
      end
    end

    def run_request(eval_method)
      return self if @loaded
      @loaded = true
      req_query = @request_params[:query] || {}
      if (eval_method == :all || accepted_queries.include?('limit')) && !(req_query[:from] || req_query[:limit] || request_params[:skip_pages])
        items_per_page = 200
        (0..100).each do |page|
          query = req_query.merge(from: 0 + (items_per_page * page), limit: items_per_page)
          query[:from] += 1 if query[:from] > 0 # WTF bug with from-limit on zoho server!
          query.merge!(sortBy: 'createdTime') if accepted_queries.include?('sortBy') && !query[:sortBy]
          arr = new_collection(query: query).run_request(__method__)
          arr.each { |x| self.push(x) }
          break unless arr.count == items_per_page
        end
      else
        parent.connector.load_by_api(collection_url, req_query)&.each do |item_data|
          raise("ERROR in ZohoService gem. item_data=[#{item_data}]") unless item_data.is_a?(Hash)
          self.push(request_params[:items_class].new(parent, item_data))
        end
      end
      self
    end

    def new(item_params)
      if accepted_queries.include?('departmentId')
        item_params[:departmentId] ||= parent.connector.client_params[:departmentId]
      end
      request_params[:items_class].new(parent, item_params)
    end

    def create(item_params)
      new(item_params).save!
    end

    def find_or_initialize_by(params, create_params = {})
      find(params).first || create(params.deep_merge(create_params))
    end

    def find(params)
      # this method not normal! It is temporary! Search method not working normal on the desk.zoho.com.
      # use "search" method if you want search only in texts of a model.
      params = params ? params.deep_symbolize : {}
      select { |x| x.to_h.deep_symbolize.deep_include?(params) }
    end

    def find_with_str(searchStr, params = {})
      search(searchStr).find(params)
    end

    def by_id(id)
      request_params[:items_class].new_by_id(parent, id)
    end

    def search(searchStr) # Search method can search only searchStr in texts of a model :( . it`s not good practice :(.
      new_collection(query: { searchStr: searchStr, 'module': request_params[:items_class].models_name,
                              sortBy: 'relevance' })
    end

    def all
      run_request(__method__)
    end

    def accepted_queries
      if request_params[:query] && request_params[:searchStr]
        ['from', 'limit', 'sortBy', 'departmentId']
      else
        mod = request_params[:items_class]
        mod.model_params &&  mod.model_params[:queries] ? mod.model_params[:queries] : []
      end
    end

    def first(*args, &block)
      if !@loaded && accepted_queries.include?('limit')
        return new_collection({ query: { limit: 1 } }).run_request(__method__).first(*args, &block)
      end
      run_request(__method__)
      super(*args, &block)
    end

    def new_collection(more_params)
      self.class.new(parent, request_params.deep_merge(more_params))
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
