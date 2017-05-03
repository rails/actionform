module ActionForm
  class Base
    include ActiveModel::Model
    include FormHelpers
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
    
    def get_model(assoc_name)
      form = find_form_by_assoc_name(assoc_name)
      form.get_model(assoc_name)
    end

    def save!
      save or raise ActiveRecord::RecordInvalid.new(self)
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

    class << self
      attr_writer :main_class, :main_model
      delegate :reflect_on_association, to: :main_class

      def attributes(*names)
        options = names.pop if names.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of(*names)
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
        forms << FormDefinition.new(name, block, options)
        macro = main_class.reflect_on_association(name).macro

        case macro
        when :has_one, :belongs_to
          class_eval "def #{name}; @#{name}; end"
        when :has_many
          class_eval "def #{name}; @#{name}.models; end"
        end

        class_eval "def #{name}_attributes=; end"
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

  end
end
