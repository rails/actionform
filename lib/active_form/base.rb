module ActiveForm
  class Base
    include ActiveModel::Model
    extend ActiveModel::Callbacks

    define_model_callbacks :save, only: [:after]
    after_save :update_form_models

    delegate :persisted?, :to_model, :to_key, :to_param, :to_partial_path, to: :model
    attr_reader :model

    # Compatibility method
    def forms
      @nested_forms
    end

    def initialize(model)
      @model = model
      @nested_forms = []
      populate_forms
    end

    def submit(params)
      params.each do |key, value|
        if nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          send("#{key}=", value)
        end
      end
    end

    def get_model(association_name)
      form_representing(association_name).get_model(association_name)
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
      delegate :reflect_on_association, to: :model_class

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

      def association(name, options = {}, &block)
        case model_class.reflect_on_association(name).macro
        when :has_one, :belongs_to
          attr_reader name
        when :has_many
          define_method name do
            instance_variable_get("@#{name}").models
          end
        end

        forms << FormDefinition.new(name, block, options)
        define_method("#{name}_attributes=") {}
      end

      def forms
        @forms ||= []
      end

      private
        def model_class
          @model_class ||= main_model.to_s.camelize.constantize
        end
    end

    private

    def update_form_models
      nested_forms.each(&:update_models)
    end

    def populate_forms
      self.class.forms.each do |definition|
        definition.parent = model
        definition.to_form.tap do |nested_form|
          nested_forms << nested_form
          instance_variable_set("@#{definition.assoc_name}", nested_form)
        end
      end
    end

    attr_reader :nested_forms

    def nested_params?(value)
      value.is_a?(Hash)
    end

    def extract_association_name(association)
      $1.to_sym if /\A(.+)_attributes\z/ =~ association
    end

    def fill_association_with_attributes(association, attributes)
      name = extract_association_name(association)
      form_representing(name).submit(attributes)
    end

    def form_representing(association_name)
      nested_forms.find { |form| form.represents?(association_name) }
    end

    def aggregate_form_errors
      nested_forms.each do |form|
        form.valid?
        collect_errors_from(form)
      end
    end

    def collect_errors_from(validatable_object)
      validatable_object.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
  end

end
