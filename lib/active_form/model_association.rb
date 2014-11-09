require 'active_support/core_ext/module/delegation'
require 'active_form/associatable'

module ActiveForm
  class ModelAssociation
    include Associatable
    include ActiveModel::Model

    attr_accessor :parent_association

    def initialize(model_name, options = {})
      @model_name = model_name
      @options = options
    end

    def add_child(child, block = nil)
      children << child
      child.parent_association = self
      child.instance_eval(&block) if block
    end

    # Test compatibility method
    def forms
      @children
    end

    def instance=(instance)
      @model = instance if instance.is_a?(model_class)
    end

    def attributes(*attribute_names)
      options = attribute_names.extract_options!

      delegate_accessors_to_model attribute_names, options[:prefix]

      if options && options[:required]
        validates_presence_of(*attribute_names)
      end
    end
    alias :attribute :attributes

    def attributes=(attributes)
      attributes.each do |name, value|
        self.public_send("#{name}=", value)
      end if attributes
    end

    def model
      @model ||= model_class.new
    end

    delegate :persisted?, to: :model

    def dynamic?
      false
    end

    def save
      aggregate(&:save)
    end

    def valid?
      aggregate(&:valid?)
    end

    delegate :reflect_on_association, to: :model_class

    private
      def children
        @children ||= []
      end

      def reflection
        parent_association.reflect_on_association(@name)
      end

      def model_class
        @model_class ||= @model_name.to_s.singularize.camelize.constantize
      end

      def delegate_accessors_to_model(names, prefix = false)
        names.each do |attr|
          self.class.delegate attr, "#{attr}=", to: :model, prefix: prefix
        end
      end

      def aggregate
        yield model
        children.each { |c| yield c }
      end
  end
end
