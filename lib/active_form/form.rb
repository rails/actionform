module ActiveForm
  class Form
    include ActiveModel::Validations

    delegate :id, :_destroy, :persisted?, to: :model
    attr_reader :association_name, :parent, :model, :forms, :proc

    def initialize(assoc_name, parent, proc, model=nil)
      @association_name = assoc_name
      @parent = parent
      @model = assign_model(model)
      @forms = []
      @proc = proc
      enable_autosave
    end

    def class
      model.class
    end

    def association(name, options={}, &block)
      macro = model.class.reflect_on_association(name).macro
      form_definition = FormDefinition.new(name, block, options)
      form_definition.parent = @model

      case macro
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

    def method_missing(method_sym, *arguments, &block)
      if method_sym =~ /^validates?$/
        class_eval do
          send(method_sym, *arguments, &block)
        end
      end
    end

    def update_models
      @model = parent.send("#{association_name}")
    end

    REJECT_ALL_BLANK_PROC = proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

    def call_reject_if(attributes)
      REJECT_ALL_BLANK_PROC.call(attributes)
    end

    def params_for_current_scope(attributes)
      attributes.dup.reject { |_, v| v.is_a? Hash }
    end

    def submit(params)
      reflection = association_reflection

      if reflection.macro == :belongs_to
        @model = parent.send("build_#{association_name}") unless call_reject_if(params_for_current_scope(params))
      end

      params.each do |key, value|
        if nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          model.send("#{key}=", value)
        end
      end
    end

    def get_model(assoc_name)
      if represents?(assoc_name)
        form = Form.new(association_name, parent, proc)
        form.instance_eval &proc
        form
      else
        form = find_form_by_assoc_name(assoc_name)
        form.get_model(assoc_name)
      end
    end

    def delete
      model.mark_for_destruction
    end

    def valid?
      super
      model.valid?

      collect_errors_from(model)
      aggregate_form_errors

      errors.empty?
    end

    def represents?(assoc_name)
      association_name.to_s == assoc_name.to_s
    end

    private

    ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

    def enable_autosave
      reflection = association_reflection
      reflection.autosave = true
    end

    def fill_association_with_attributes(association, attributes)
      assoc_name = find_association_name_in(association).to_sym
      form = find_form_by_assoc_name(assoc_name)

      form.submit(attributes)
    end

    def find_form_by_assoc_name(assoc_name)
      forms.select { |form| form.represents?(assoc_name) }.first
    end

    def nested_params?(value)
      value.is_a?(Hash)
    end

    def find_association_name_in(key)
      ATTRIBUTES_KEY_REGEXP.match(key)[1]
    end

    def association_reflection
      parent.class.reflect_on_association(association_name)
    end

    def build_model
      macro = association_reflection.macro

      case macro
      when :belongs_to
        if parent.send("#{association_name}")
          parent.send("#{association_name}")
        else
          association_reflection.klass.new
        end
      when :has_one
        fetch_or_initialize_model
      when :has_many
        parent.send(association_name).build
      end
    end

    def fetch_or_initialize_model
      if parent.send("#{association_name}")
        parent.send("#{association_name}")
      else
        parent.send("build_#{association_name}")
      end
    end

    def assign_model(model)
      if model
        model
      else
        build_model
      end
    end

    def aggregate_form_errors
      forms.each do |form|
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