require 'active_form/abstract_form'

module ActiveForm
  class Form < AbstractForm
    include ActiveModel::Validations

    delegate :id, :_destroy, :persisted?, to: :model
    attr_reader :association_name, :parent, :model, :forms, :proc

    def initialize(assoc_name, parent, proc, model=nil)
      @association_name = assoc_name
      @parent = parent
      @model = model || build_model
      @forms = []
      instance_eval(&proc) if proc
      enable_autosave
    end

    def class
      model.class
    end

    def association(name, options={}, &block)
      form_definition = FormDefinition.new(name, block, options)
      form_definition.parent = @model

      case model.class.reflect_on_association(name).macro
      when :has_one, :belongs_to
        class_eval "def #{name}; @#{name}; end"
      when :has_many
        class_eval "def #{name}; @#{name}.models; end"
      end

      nested_form = form_definition.to_form
      @forms << nested_form
      instance_variable_set("@#{name}", nested_form)

      class_eval "def #{name}_attributes=; end"
    end

    def attributes(*arguments)
      class_eval do
        options = arguments.pop if arguments.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of *arguments
        end

        arguments.each do |attribute|
          delegate attribute, "#{attribute}=", to: :model
        end
      end
    end

    alias_method :attribute, :attributes

    def method_missing(method, *args, &block)
      self.class.send(method, *args, &block) if method =~ /\Avalidates?\z/
    end

    def update_models
      @model = parent.send(association_name)
    end

    def reject_nested_params(params)
      params.reject { |_, v| nested_params?(v) }
    end

    def submit(params)
      if belongs_to_association? && !reject_form?(reject_nested_params(params))
        @model = parent.send("build_#{association_name}")
      end

      super
    end

    def get_model(assoc_name)
      if represents?(assoc_name)
        build_form
      else
        find_form_by_assoc_name(assoc_name).get_model(assoc_name)
      end
    end

    def delete
      model.mark_for_destruction
    end

    private

    ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

    def enable_autosave
      association_reflection.autosave = true
    end

    def fill_association_with_attributes(association, attributes)
      assoc_name = find_association_name_in(association).to_sym
      form = find_form_by_assoc_name(assoc_name)

      form.submit(attributes)
    end

    def find_form_by_assoc_name(assoc_name)
      forms.find { |form| form.represents?(assoc_name) }
    end

    def find_association_name_in(key)
      ATTRIBUTES_KEY_REGEXP.match(key)[1]
    end

    def association_reflection
      parent.class.reflect_on_association(association_name)
    end

    def belongs_to_association?
      association_reflection.macro == :belongs_to
    end

    def build_model
      case association_reflection.macro
      when :belongs_to
        parent.send(association_name) || association_reflection.klass.new
      when :has_one
        parent.send(association_name) || parent.send("build_#{association_name}")
      when :has_many
        parent.send(association_name).build
      end
    end
  end
end
