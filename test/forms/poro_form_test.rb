require 'test_helper'
require_relative 'poro_form_fixture'

class PoroFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  setup do
    @poro = Poro.new
    @form = PoroFormFixture.new(@poro)
    @model = @form
  end


  test "main form validates itself" do
    params = {
      name: "Euruco",
      city: "Athens"
    }

    @form.submit(params)

    assert @form.valid?

    @form.submit({ name: nil, city: nil })

    assert_not @form.valid?
    assert_includes @form.errors[:name], "can't be blank"
    assert_includes @form.errors[:city], "can't be blank"
  end

  test "save works" do
    params = {
      name: "Euruco",
      city: "Athens"
    }

    @form.submit(params)

    assert @form.save
  end
end
