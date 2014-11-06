module ActiveForm
  module ViewHelpers

    def link_to_remove_association(name, f, html_options={})
      classes = []
      classes << "remove_fields"

      is_existing = f.object.persisted?
      classes << (is_existing ? 'existing' : 'dynamic')
      
      wrapper_class = html_options.delete(:wrapper_class)
      html_options[:class] = [html_options[:class], classes.join(' ')].compact.join(' ')
      html_options[:'data-wrapper-class'] = wrapper_class if wrapper_class.present?

      if is_existing
        f.hidden_field(:_destroy) + link_to(name, '#', html_options)
      else
        link_to(name, '#', html_options)
      end
    end

    def render_association(association, f, new_object, render_options={}, custom_partial=nil)
      partial = get_partial_path(custom_partial, association)
      
      if f.respond_to?(:semantic_fields_for)
        method_name = :semantic_fields_for
      elsif f.respond_to?(:simple_fields_for)
        method_name = :simple_fields_for
      else
        method_name = :fields_for
      end

      f.send(method_name, association, new_object, {:child_index => "new_#{association}"}.merge(render_options)) do |builder|
        render(partial: partial, locals: {:f => builder})
      end
    end

    def link_to_add_association(name, f, association, html_options={})
      render_options = html_options.delete(:render_options)
      render_options ||= {}
      override_partial = html_options.delete(:partial)

      html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
      html_options[:'data-association'] = association.to_s

      new_object = create_object(f, association)

      html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(association, f, new_object, render_options, override_partial).to_str).html_safe

      link_to(name, '#', html_options)
    end

    def create_object(f, association)
      f.object.get_model(association)
    end

    def get_partial_path(partial, association)
      partial ? partial : association.to_s.singularize + "_fields"
    end
  end
end
