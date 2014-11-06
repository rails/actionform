module ActiveForm
  class AbstractForm
    include ActiveModel::Validations

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
          fill_association_with_attributes(key, value)
        else
          send("#{key}=", value)
        end
      end
    end

    private
      def nested_params?(params)
        params.is_a?(Hash)
      end

      def reject_form?(params)
        params.all? { |k, v| k == '_destroy' || v.blank? }
      end

      def build_form(model = nil)
        Form.new(association_name, parent, proc, model)
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
