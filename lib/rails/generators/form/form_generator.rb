require 'rails/generators'
require 'rails/generators/named_base'

module Rails
  module Generators # :nodoc:
    class FormGenerator < Rails::Generators::NamedBase # :nodoc:
      desc 'This generator creates an action form file at app/forms'

      check_class_collision suffix: 'Form'

      hook_for :test_framework

      argument :attributes, type: :array, default: [], banner: "field1 field2 field3"

      def self.default_generator_root
        File.dirname(__FILE__)
      end

      def create_form_file
        template 'form.rb', File.join('app/forms', class_path, "#{file_name}_form.rb")
      end
    end
  end
end
