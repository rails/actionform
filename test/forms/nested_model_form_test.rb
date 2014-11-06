require 'test_helper'
require_relative '../fixtures/user_with_email_form_fixture'

class NestedModelFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :users, :emails

  def setup
    @user = User.new
    @form = UserWithEmailFormFixture.new(@user)
    @email_form = @form.email
    @model = @form
  end

  test "declares association" do
    assert_respond_to UserWithEmailFormFixture, :association
  end

  test "contains a list of sub-forms" do
    assert_respond_to UserWithEmailFormFixture, :forms
  end

  test "forms list contains form definitions" do
    email_definition = UserWithEmailFormFixture.forms.first

    assert_equal :email, email_definition.assoc_name
  end

  test "contains getter for email sub-form" do
    assert_respond_to @form, :email
    assert_instance_of ActiveForm::Form, @form.email
  end

  test "email sub-form contains association name and parent model" do
    assert_equal :email, @email_form.association_name
    assert_equal @user, @email_form.parent
  end

  test "email sub-form initializes model for new parent" do
    assert_instance_of Email, @email_form.model
    assert_equal @form.model.email, @email_form.model
    assert @email_form.model.new_record?
  end

  test "email sub-form fetches model for existing parent" do
    user = users(:peter)
    user_form = UserWithEmailFormFixture.new(user)
    email_form = user_form.email

    assert_instance_of Email, email_form.model
    assert_equal user_form.model.email, email_form.model
    assert email_form.persisted?

    assert_equal "m-peter", user_form.name
    assert_equal 23, user_form.age
    assert_equal 0, user_form.gender
    assert_equal "markoupetr@gmail.com", email_form.address
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    assert @email_form.represents?("email")
    assert_not @email_form.represents?("profile")
  end

  test "email sub-form declares attributes" do
    [:address, :address=].each do |attribute|
      assert_respond_to @email_form, attribute
    end
  end

  test "email sub-form delegates attributes to model" do
    @email_form.address = "petrakos@gmail.com"

    assert_equal "petrakos@gmail.com", @email_form.address
    assert_equal "petrakos@gmail.com", @email_form.model.address
  end

  test "email sub-form validates itself" do
    @email_form.address = nil

    assert_not @email_form.valid?
    assert_includes @email_form.errors.messages[:address], "can't be blank"

    @email_form.address = "petrakos@gmail.com"

    assert @email_form.valid?
  end

  test "email sub-form validates the model" do
    existing_email = emails(:peters)
    @email_form.address = existing_email.address

    assert_not @email_form.valid?
    assert_includes @email_form.errors.messages[:address], "has already been taken"

    @email_form.address = "petrakos@gmail.com"

    assert @email_form.valid?
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      }
    }

    @form.submit(params)

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @email_form.address
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count']) do
      @form.save
    end

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @email_form.address

    assert @form.persisted?
    assert @email_form.persisted?
  end

  test "main form updates its model and the models in nested sub-forms" do
    user = users(:peter)
    form = UserWithEmailFormFixture.new(user)
    params = {
      name: "Petrakos",
      age: 24,
      gender: 0,

      email_attributes: {
        address: "cs3199@teilar.gr"
      }
    }

    form.submit(params)

    assert_difference(['User.count', 'Email.count'], 0) do
      form.save
    end

    assert_equal "Petrakos", form.name
    assert_equal 24, form.age
    assert_equal 0, form.gender
    assert_equal "cs3199@teilar.gr", form.email.address
  end

  test "main form collects all the model related errors" do
    peter = users(:peter)
    params = {
      name: peter.name,
      age: "23",
      gender: "0",

      email_attributes: {
        address: peter.email.address
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count'], 0) do
      @form.save
    end

    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_includes @form.errors.messages[:address], "has already been taken"
  end

  test "main form collects all the form specific errors" do
    params = {
      name: nil,
      age: nil,
      gender: nil,

      email_attributes: {
        address: nil
      }
    }

    @form.submit(params)

    assert_not @form.valid?

    [:name, :age, :gender, :address].each do |attribute|
      assert_includes @form.errors.messages[attribute], "can't be blank"
    end
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :email_attributes=
  end
end