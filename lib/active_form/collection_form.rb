module ActiveForm
  class CollectionForm
    include ActiveModel::Validations

    attr_reader :association_name, :records, :parent, :proc, :forms

    def initialize(assoc_name, parent, proc, options)
      @association_name = assoc_name
      @parent = parent
      @proc = proc
      @records = options[:records] || 1
      @forms = []
      assign_forms
    end

    def update_models
      @forms = []
      fetch_models
    end

    def submit(params)
      params.each do |key, attributes|
        if parent.persisted?
          create_or_update_record(attributes)
        else
          create_or_assign_record(key, attributes)
        end
      end
    end

    def get_model(assoc_name)
      form = Form.new(assoc_name, parent, proc)
      form.instance_eval &proc
      form
    end

    def valid?
      aggregate_form_errors

      errors.empty?
    end

    def represents?(assoc_name)
      association_name.to_s == assoc_name.to_s
    end

    def models
      forms
    end

    def each
      forms.each do |form|
        yield form
      end
    end

    private

    UNASSIGNABLE_KEYS = %w( id _destroy )

    def reject_form?(attributes)
      attributes.all? { |key, value| key == '_destroy' || value.blank? }
    end

    def existing_record?(attributes)
      attributes[:id] != nil
    end

    def update_record(attributes)
      form = form_for_id(attributes[:id].to_i)

      form.submit(attributes.except(*UNASSIGNABLE_KEYS))

      destroy_form!(form) if attributes['_destroy'] == "1"
    end

    def create_record(attributes)
      build_form.submit(attributes)
    end

    def create_or_update_record(attributes)
      if existing_record?(attributes)
        update_record(attributes)
      else
        create_record(attributes)
      end
    end

    def create_or_assign_record(key, attributes)
      i = key.to_i

      if dynamic_key?(i)
        create_record(attributes)
      else
        forms[i].delete if reject_form?(attributes)

        forms[i].submit(attributes)
      end
    end

    def assign_forms
      if parent.persisted?
        fetch_models
      else
        initialize_models
      end
    end

    def dynamic_key?(i)
      i > forms.size
    end

    def aggregate_form_errors
      forms.each do |form|
        form.valid?
        collect_errors_from(form)
      end
    end

    def fetch_models
      associated_records.each { |model| build_form(model) }
    end

    def initialize_models
      records.times { build_form }
    end

    def collect_errors_from(model)
      model.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end

    def form_for_id(id)
     forms.find { |form| form.id == id }
    end

    def destroy_form!(form)
      form.delete
      forms.delete(form)
    end

    def build_form(model = nil)
      Form.new(association_name, parent, proc, model).tap do |form|
        forms << form
        form.instance_eval &proc
      end
    end

    def associated_records
      parent.send(association_name)
    end
  end
end
