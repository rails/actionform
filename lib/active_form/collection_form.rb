require 'active_form/abstract_form'

module ActiveForm
  class CollectionForm < AbstractForm
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

    def valid?
      aggregate_form_errors

      errors.empty?
    end

    def models
      forms
    end

    def each
      forms.each(&Proc.new)
    end

    private

    UNASSIGNABLE_KEYS = %w( id _destroy )

    def existing_record?(attributes)
      attributes[:id] != nil
    end

    def update_record(attributes)
      form = form_for_id(attributes[:id].to_i)

      form.submit(attributes.except(*UNASSIGNABLE_KEYS))

      destroy_form!(form) if attributes['_destroy'] == "1"
    end

    def create_record(attributes)
      build_form.tap { |f| forms << f }.submit(attributes)
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

    def fetch_models
      associated_records.each { |model| forms << build_form(model) }
    end

    def initialize_models
      records.times { forms << build_form }
    end

    def form_for_id(id)
     forms.find { |form| form.id == id }
    end

    def destroy_form!(form)
      form.delete
      forms.delete(form)
    end

    def build_form(model = nil)
      Form.new(association_name, parent, proc, model)
    end

    def associated_records
      parent.send(association_name)
    end
  end
end
