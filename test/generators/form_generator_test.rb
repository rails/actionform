require 'test_helper'
require 'rails/generators/test_case'
require 'rails/generators/form/form_generator'

class FormGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::FormGenerator

  destination File.expand_path("../../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  def test_help
    content = run_generator ["--help"]
    assert_match(/creates an action form file/, content)
  end

  def test_form_is_created
    run_generator ["inquiry"]
    assert_file "app/forms/inquiry_form.rb", /class InquiryForm < ActionForm::Base/
  end

  def test_form_with_attributes
    run_generator ["feedback", "name", "email", "phone"]
    assert_file "app/forms/feedback_form.rb", /class FeedbackForm < ActionForm::Base/
    assert_file "app/forms/feedback_form.rb", /attributes :name, :email, :phone/
  end

  def test_namespaced_forms
    run_generator ["admin/feedback"]
    assert_file "app/forms/admin/feedback_form.rb", /class Admin::FeedbackForm < ActionForm::Base/
  end
end
