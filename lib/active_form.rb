require 'active_form/base'
require 'active_form/form'
require 'active_form/form_collection'
require 'active_form/form_definition'
require 'active_form/errors'
require 'active_form/multiparameter_attribute'
require 'active_form/view_helpers'

module ActiveForm
  class Engine < ::Rails::Engine
    initializer "active_form.initialize" do |app|
      ActiveSupport.on_load :action_view do
        include ActiveForm::ViewHelpers
      end
    end
  end
end
