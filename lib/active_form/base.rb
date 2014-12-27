module ActiveForm
  class Base
    include ActiveModel::Model
    extend ActiveModel::Callbacks

    define_model_callbacks :save, only: [:after]
    after_save :update_form_models

    delegate :persisted?, :to_model, :to_key, :to_param, :to_partial_path, to: :model
    attr_reader :model, :forms

    def initialize(model)
      @model = model
      @forms = []
      populate_forms
    end

    def submit(params)
      multi_parameter_attributes  = []

      params.each do |key, value|
        if key.to_s.include?("(")
          multi_parameter_attributes << [ key, value ]
        elsif nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          send("#{key}=", value)
        end
      end

      if multi_parameter_attributes.present?
        assign_multiparameter_attributes(multi_parameter_attributes)
      end
    end

    def get_model(assoc_name)
      form = find_form_by_assoc_name(assoc_name)
      form.get_model(assoc_name)
    end

    def save
      if valid?
        run_callbacks :save do
          ActiveRecord::Base.transaction do
              model.save
          end
        end
      else
        false
      end
    end

    def valid?
      super
      model.valid?

      collect_errors_from(model)
      aggregate_form_errors

      errors.empty?
    end

    class << self
      attr_accessor :main_class
      attr_writer :main_model
      delegate :reflect_on_association, to: :main_class

      def attributes(*names)
        options = names.pop if names.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of *names
        end

        names.each do |attribute|
          delegate attribute, "#{attribute}=", to: :model
        end
      end

      def main_class
        @main_class ||= main_model.to_s.camelize.constantize
      end

      def main_model
        @main_model ||= name.sub(/Form$/, '').singularize
      end

      alias_method :attribute, :attributes

      def association(name, options={}, &block)
        macro = main_class.reflect_on_association(name).macro

        case macro
        when :has_one, :belongs_to
          declare_form(name, &block)
        when :has_many
          declare_form_collection(name, options, &block)
        end

        define_method("#{name}_attributes=") {}
      end

      def declare_form_collection(name, options={}, &block)
        forms << FormDefinition.new(name, block, options)
        class_eval("def #{name}; @#{name}.models; end")
      end

      def declare_form(name, &block)
        forms << FormDefinition.new(name, block)
        attr_reader name
      end

      def forms
        @forms ||= []
      end
    end

    private

    def update_form_models
      forms.each do |form|
        form.update_models
      end
    end

    def populate_forms
      self.class.forms.each do |definition|
        definition.parent = model
        nested_form = definition.to_form
        forms << nested_form
        name = definition.assoc_name
        instance_variable_set("@#{name}", nested_form)
      end
    end

    def nested_params?(value)
      value.is_a?(Hash)
    end

    ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

    def find_association_name_in(key)
      ATTRIBUTES_KEY_REGEXP.match(key)[1]
    end

    def fill_association_with_attributes(association, attributes)
      assoc_name = find_association_name_in(association).to_sym
      form = find_form_by_assoc_name(assoc_name)

      form.submit(attributes)
    end

    def find_form_by_assoc_name(assoc_name)
      forms.select { |form| form.represents?(assoc_name) }.first
    end

    def aggregate_form_errors
      forms.each do |form|
        form.valid?
        collect_errors_from(form)
      end
    end

    def collect_errors_from(validatable_object)
      validatable_object.errors.each do |attribute, error|
        key = if validatable_object.respond_to?(:association_name)
          "#{validatable_object.association_name}.#{attribute}"
        else
          attribute
        end

        errors.add(key, error)
      end
    end

    def assign_multiparameter_attributes(pairs)
      execute_callstack_for_multiparameter_attributes(
        extract_callstack_for_multiparameter_attributes(pairs)
      )
    end

    def execute_callstack_for_multiparameter_attributes(callstack)
      errors = []
      callstack.each do |name, values_with_empty_parameters|
        begin
          send("#{name}=", MultiparameterAttribute.new(self, name, values_with_empty_parameters).read_value)
        rescue => ex
          errors << AttributeAssignmentError.new("error on assignment #{values_with_empty_parameters.values.inspect} to #{name} (#{ex.message})", ex, name)
        end
      end
      if errors.present?
        error_descriptions = errors.map { |ex| ex.message }.join(",")
        raise MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes [#{error_descriptions}]"
      end
    end

    def extract_callstack_for_multiparameter_attributes(pairs)
      attributes = {}

      pairs.each do |(multiparameter_name, value)|
        attribute_name = multiparameter_name.split("(").first
        attributes[attribute_name] ||= {}

        parameter_value = value.empty? ? nil : type_cast_attribute_value(multiparameter_name, value)
        attributes[attribute_name][find_parameter_position(multiparameter_name)] ||= parameter_value
      end

      attributes
    end

    def type_cast_attribute_value(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
    end

    def find_parameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first.to_i
    end
  end

end
