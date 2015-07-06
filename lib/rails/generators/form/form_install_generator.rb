require 'rails/generators'
require 'rails/generators/base'

module Rails
  module Generators
    class FormInstallGenerator < Rails::Generators::Base

      desc "Creates a forms directory into your app and test directories and includes the necessary JS file."

      def create_forms_app_directory
        empty_directory "app/forms"
      end

      def create_forms_test_directory
        if File.directory?("spec")
          empty_directory "spec/forms"
        else
          empty_directory "test/forms"
        end
      end

      def include_js_file
        insert_into_file "app/assets/javascripts/application.js", "//= require action_form", :before => "//= require_tree ."
      end
    end
  end
end
