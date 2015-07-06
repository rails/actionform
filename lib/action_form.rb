module ActionForm
  autoload :Base, 'action_form/base'
  autoload :Form, 'action_form/form'
  autoload :FormCollection, 'action_form/form_collection'
  autoload :FormDefinition, 'action_form/form_definition'
  autoload :TooManyRecords, 'action_form/too_many_records'
  autoload :ViewHelpers, 'action_form/view_helpers'
  autoload :FormHelpers, 'action_form/form_helpers'

  class Engine < ::Rails::Engine
    initializer "action_form.initialize" do |app|
      ActiveSupport.on_load :action_view do
        include ActionForm::ViewHelpers
      end
    end
  end
end
