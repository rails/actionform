require 'test_helper'

class NestedModelsFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :users, :emails, :profiles

  def setup
    @user = User.new
    @form = UserForm.new(@user)
    @profile_form = @form.profile
    @model = @form
  end

  test "declares both sub-forms" do
    assert_equal 2, @form.forms.size
  end

  test "profile sub-form contains association name and parent" do
    assert_equal :profile, @profile_form.association_name
    assert_equal @user, @profile_form.parent
  end

  test "profile sub-form declares attributes" do
    attributes = [:twitter_name, :twitter_name=, :github_name, :github_name=]

    attributes.each do |attribute|
      assert_respond_to @profile_form, attribute
    end
  end

  test "profile sub-form delegates attributes to model" do
    @profile_form.twitter_name = "twitter_peter"
    @profile_form.github_name = "github_peter"

    assert_equal "twitter_peter", @profile_form.twitter_name
    assert_equal "twitter_peter", @profile_form.model.twitter_name

    assert_equal "github_peter", @profile_form.github_name
    assert_equal "github_peter", @profile_form.model.github_name
  end

  test "profile sub-form initializes model for new parent" do
    assert_instance_of Profile, @profile_form.model
    assert_equal @form.model.profile, @profile_form.model
    assert @profile_form.model.new_record?
  end

  test "profile sub-form fetches model for existing parent" do
    user = users(:peter)
    user_form = UserForm.new(user)
    profile_form = user_form.profile

    assert_instance_of Profile, profile_form.model
    assert_equal user_form.model.profile, profile_form.model
    assert profile_form.persisted?

    assert_equal "m-peter", user_form.name
    assert_equal 23, user_form.age
    assert_equal 0, user_form.gender
    assert_equal "twitter_peter", profile_form.model.twitter_name
    assert_equal "github_peter", profile_form.model.github_name
  end

  test "profile sub-form validates itself" do
    @profile_form.twitter_name = nil
    @profile_form.github_name = nil

    assert_not @profile_form.valid?
    [:twitter_name, :github_name].each do |attribute|
      assert_includes @profile_form.errors.messages[attribute], "can't be blank"
    end

    @profile_form.twitter_name = "t-peter"
    @profile_form.github_name = "g-peter"

    assert @profile_form.valid?
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      },

      profile_attributes: {
        twitter_name: "t_peter",
        github_name: "g_peter"
      }
    }

    @form.submit(params)

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @form.email.address
    assert_equal "t_peter", @profile_form.twitter_name
    assert_equal "g_peter", @profile_form.github_name
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      },

      profile_attributes: {
        twitter_name: "t_peter",
        github_name: "g_peter"
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count', 'Profile.count']) do
      @form.save
    end

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @form.email.address
    assert_equal "t_peter", @profile_form.twitter_name
    assert_equal "g_peter", @profile_form.github_name

    assert @form.persisted?
    assert @form.email.persisted?
    assert @profile_form.persisted?
  end

  test "main form updates its model and the models in nested sub-forms" do
    user = users(:peter)
    form = UserForm.new(user)
    params = {
      name: "Petrakos",
      age: 24,
      gender: 0,

      email_attributes: {
        address: "cs3199@teilar.gr"
      },

      profile_attributes: {
        twitter_name: "peter_t",
        github_name: "peter_g"
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
    assert_equal "peter_t", form.profile.twitter_name
    assert_equal "peter_g", form.profile.github_name
  end

  test "main form collects all the model related errors" do
    peter = users(:peter)
    params = {
      name: peter.name,
      age: "23",
      gender: "0",

      email_attributes: {
        address: peter.email.address
      },

      profile_attributes: {
        twitter_name: peter.profile.twitter_name,
        github_name: peter.profile.github_name
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count', 'Profile.count'], 0) do
      @form.save
    end

    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_includes @form.errors.messages[:address], "has already been taken"
    assert_includes @form.errors.messages[:twitter_name], "has already been taken"
    assert_includes @form.errors.messages[:github_name], "has already been taken"
  end

  test "main form collects all the form specific errors" do
    params = {
      name: nil,
      age: nil,
      gender: nil,

      email_attributes: {
        address: nil
      },

      profile_attributes: {
        twitter_name: nil,
        github_name: nil
      }
    }

    @form.submit(params)

    assert_not @form.valid?

    [:name, :age, :gender, :address, :twitter_name, :github_name].each do |attribute|
      assert_includes @form.errors.messages[attribute], "can't be blank"
    end
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :email_attributes=
    assert_respond_to @form, :profile_attributes=
  end
end
