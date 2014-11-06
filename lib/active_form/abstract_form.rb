module ActiveForm
  class AbstractForm
    include ActiveModel::Validations

    def backing_form_for(association)
      forms.find { |form| form.represents?(association) }
    end

    def represents?(association)
      association_name.to_s == association.to_s
    end

    def valid?
      super
      model.valid?

      collect_errors_from(model)
      aggregate_form_errors

      errors.empty?
    end

    def submit(params)
      params.each do |key, value|
        if nested_params?(value)
          assign_association_attributes(key, value)
        else
          send("#{key}=", value)
        end
      end
    end

    def models
      self
    end

    private
      def nested_params?(params)
        params.is_a?(Hash)
      end

      def reject_form?(params)
        params.all? { |k, v| k == '_destroy' || v.blank? }
      end

      def extract_association_name(association)
        $1.to_sym if /\A(.+)_attributes\z/ =~ association
      end

      def assign_association_attributes(association, attributes)
        name = extract_association_name(association)
        backing_form_for(name).submit(attributes)
      end

      def aggregate_form_errors
        forms.each do |form|
          form.valid?
          collect_errors_from(form)
        end
      end

      def collect_errors_from(model)
        model.errors.each do |attribute, error|
          errors.add(attribute, error)
        end
      end
  end
end
