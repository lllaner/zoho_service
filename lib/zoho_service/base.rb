require 'ostruct'

module ZohoService
  class Base < OpenStruct
    attr_reader :parent, :item_id, :table, :full_data, :errors, :childs, :saved

    def initialize(parent = nil, data = nil, params = {})
      @childs = {}
      @errors = []
      @parent = parent
      @item_id = params[:item_id] || ((data && data['id']) ? data['id'] : nil)
      super(data)
      @full_data = params[:full_data]
    end

    def connector
      parent ? parent.connector : self
    end

    def get_parent(model, params = {})
      parent
    end

    def get_childs(child_model, childs_class)
       @childs[child_model] ||= ApiCollection.new(self, { items_class: childs_class})
       @childs[child_model]
    end

    def full
      load_full unless @full_data
      self
    end

    def load_full(data = nil)
      raise('You must save model before take full data in ZohoService gem.') unless @item_id
      init_data(data || connector.load_by_api(resource_path))
      @full_data = true
    end

    def init_data(data)
      data.each{ |k, v| @table[k.to_sym] = v; new_ostruct_member(k); }
      @item_id = id if id && !@item_id
    end

    def update(params)
      url = @item_id ? resource_path : parent.resource_path + self.class.class_path
      response = connector.load_by_api(url, params.to_hash, { method: @item_id ? :patch : :post })
      if response
        if response.kind_of?(Array)
          raise("ERROR! create item response is Array[#{response.count}]. Try change http to https in api_url :)!")
        elsif response['message']
          @errors << response['message']
        else
          init_data(response.to_hash)
          @full_data = nil
        end
      else
        @errors << "Error while try update[#{@item_id}] url=[#{url}] params=[#{params&.to_json}]"
      end
      self
    end

    def delete
      return unless @item_id
      response = connector.load_by_api(resource_path, nil, { method: :delete })
      if response && response['message']
        @errors << response['message']
      elsif response
        @item_id = nil
        @id = nil
        @full_data = nil
      else
        @errors << 'Error while try delete'
      end
      self
    end

    def delete!
      delete
      raise("#{@errors.join("\n")}") if @errors.any?
      self
    end

    def save
      update(to_hash)
      @saved = @errors.any?
    end

    def save!
      save
      raise("#{@errors.join("\n")}") if @errors.any?
      self
    end

    def resource_path
      raise('Cant take resource_path for not saved item in ZohoService gem.') unless @item_id
      parent.resource_path + self.class.class_path(@item_id)
    end

    def to_hash
      @table.to_hash(*args, &block)
    end

    class << self
      attr_accessor :model_params
      def class_path(id = nil)
        "/#{models_name}" + (id ? '/'+id : '')
      end

      def models_name
        self.name.demodulize.pluralize.underscore
      end

      def new_by_id(parent, id)
        raise('Need id in Base::new_by_id of ZohoService gem.') unless id
        data = parent.connector.load_by_api(parent.resource_path + class_path(id))
        new(parent, data, { full_data: true })
      end
    end
  end
end
