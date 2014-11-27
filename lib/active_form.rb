require 'active_form/base'
require 'active_form/form'
require 'active_form/collection_form'
require 'active_form/form_definition'
require 'active_form/view_helpers'

module ActiveForm
  class Engine < ::Rails::Engine

    config.before_initialize do
      if config.action_view.javascript_expansions
        config.action_view.javascript_expansions[:link_helpers] = %w(link_helpers)
      end
    end

    initializer "active_form.initialize" do |app|
      ActionView::Base.send :include, ActiveForm::ViewHelpers
    end
  end
end
