require 'test_helper'
require_relative '../fixtures/user_form_fixture'

class SingleModelFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :users

  def setup
    @user = User.new
    @form = UserFormFixture.new(@user)
    @model = @form
  end

  test "accepts the model it represents" do
    assert_equal @user, @form.model
  end

  test "declares form attributes" do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]

    attributes.each do |attribute|
      assert_respond_to @form, attribute
    end
  end

  test "delegates attributes to the model" do
    @form.name = "Peter"
    @form.age = 23
    @form.gender = 0

    assert_equal "Peter", @user.name
    assert_equal 23, @user.age
    assert_equal 0, @user.gender
  end

  test "validates itself" do
    @form.name = nil
    @form.age = nil
    @form.gender = nil

    assert_not @form.valid?
    [:name, :age, :gender].each do |attribute|
      assert_includes @form.errors.messages[attribute], "can't be blank"
    end

    @form.name = "Peters"
    @form.age = 23
    @form.gender = 0

    assert @form.valid?
  end

  test "validates the model" do
    peter = users(:peter)
    @form.name = peter.name
    @form.age = 23
    @form.gender = 0

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "has already been taken"
  end

  test "sync the model with submitted data" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @form.submit(params)

    assert_equal "Peters", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
  end

  test "sync the form with existing model" do
    peter = users(:peter)
    form = UserFormFixture.new(peter)

    assert_equal "m-peter", form.name
    assert_equal 23, form.age
    assert_equal 0, form.gender
  end

  test "saves the model" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @form.submit(params)

    assert_difference('User.count') do
      @form.save
    end

    assert_equal "Peters", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
  end

  test "does not save the model with invalid data" do
    peter = users(:peter)
    params = {
      name: peter.name,
      age: "23",
      gender: nil
    }

    @form.submit(params)

    assert_difference('User.count', 0) do
      @form.save
    end

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_includes @form.errors.messages[:gender], "can't be blank"
  end

  test "updates the model" do
    peter = users(:peter)
    form = UserFormFixture.new(peter)
    params = {
      name: "Petrakos",
      age: peter.age,
      gender: peter.gender
    }

    form.submit(params)

    assert_difference('User.count', 0) do
      form.save
    end

    assert_equal "Petrakos", form.name
  end

  test "responds to #persisted?" do
    assert_respond_to @form, :persisted?
    assert_not @form.persisted?

    assert save_user
    assert @form.persisted?
  end

  test "responds to #to_key" do
    assert_respond_to @form, :to_key
    assert_nil @form.to_key

    assert save_user
    assert_equal @user.to_key, @form.to_key
  end

  test "responds to #to_param" do
    assert_respond_to @form, :to_param
    assert_nil @form.to_param

    assert save_user
    assert_equal @user.to_param, @form.to_param
  end

  test "responds to #to_partial_path" do
    assert_respond_to @form, :to_partial_path
    assert_instance_of String, @form.to_partial_path
  end

  test "responds to #to_model" do
    assert_respond_to @form, :to_model
    assert_equal @user, @form.to_model
  end

  private

  def save_user
    @form.name = "Peters"
    @form.age = 23
    @form.gender = 0

    @form.save
  end
end