require 'test_helper'
require 'rails/generators/test_case'
require 'rails/generators/form/form_install_generator'

class FormInstallGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::FormInstallGenerator

  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "assert app folder contains forms sub-folder" do
    gen = generator
    gen.create_forms_app_directory
    assert_directory "app/forms"
  end

  test "assert test folder contains forms sub-folder" do
    gen = generator
    gen.create_forms_test_directory
    assert_directory "test/forms"
  end
end
