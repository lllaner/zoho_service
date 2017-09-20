require 'httparty'
require 'ostruct'
require 'forwardable'

module ZohoService
  class Base < OpenStruct
    attr_reader :parent, :item_id, :table, :full_data

    def initialize(parent = nil, data = nil, params = {})
      @parent = parent
      @item_id = params[:item_id] || ((data && data['id']) ? data['id'] : nil)
      super(data)
      load_full(data) if params[:full_data]
    end

    def connector
      parent ? parent.connector : self
    end

    def get_parent(model, params = {})
      parent
    end

    def full
      @full_data || load_full
    end

    def load_full(data = nil)
      @full_data = OpenStruct.new(data || connector.load_by_api(resource_path))
      @full_data
    end

    def resource_path
      return '' unless @item_id
      self.class.class_path(@item_id)
    end

    def to_hash
      @table.to_hash(*args, &block)
    end

    class << self
      def class_path(id = nil)
        "/#{self.name.demodulize.pluralize.underscore}" + (id ? '/'+id : '')
      end

      def new_by_id(parent, id)
        raise('Need id in Base::new_by_id of ZohoService gem.') unless id
        data = parent.connector.load_by_api(parent.resource_path + class_path(id))
        new(parent, data, { full_data: true })
      end
    end
  end
end
