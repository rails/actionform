require 'test_helper'

class ConferenceFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  fixtures :conferences, :speakers, :presentations

  def setup
    @conference = Conference.new
    @form = ConferenceForm.new(@conference)
    @model = @form
  end

  test "contains getter for presentations sub-form" do
    assert_respond_to @form.speaker, :presentations

    presentations_form = @form.speaker.forms.first
    assert_instance_of ActiveForm::FormCollection, presentations_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    presentations_form = @form.speaker.forms.first

    assert presentations_form.represents?("presentations")
    assert_not presentations_form.represents?("presentation")
  end

  test "main form provides getter method for collection objects" do
    assert_respond_to @form.speaker, :presentations

    presentations = @form.speaker.presentations

    presentations.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Presentation, form.model
    end
  end

  test "presentations sub-form contains association name and parent model" do
    presentations_form = @form.speaker.forms.first

    assert_equal :presentations, presentations_form.association_name
    assert_equal 2, presentations_form.records
    assert_equal @form.speaker.model, presentations_form.parent
  end

  test "presentations sub-form initializes the number of records specified" do
    presentations_form = @form.speaker.forms.first

    assert_respond_to presentations_form, :models
    assert_equal 2, presentations_form.models.size

    presentations_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Presentation, form.model

      assert_respond_to form, :topic
      assert_respond_to form, :topic=
      assert_respond_to form, :duration
      assert_respond_to form, :duration=
    end

    assert_equal 2, @form.speaker.model.presentations.size
  end

  test "presentations sub-form fetches parent and association objects" do
    conference = conferences(:ruby)

    form = ConferenceForm.new(conference)

    assert_equal conference.name, form.name
    assert_equal 2, form.speaker.presentations.size
    assert_equal conference.speaker.presentations[0], form.speaker.presentations[0].model
    assert_equal conference.speaker.presentations[1], form.speaker.presentations[1].model
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Peter Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
        }
      }
    }

    @form.submit(params)

    assert_equal "Euruco", @form.name
    assert_equal "Athens", @form.city
    assert_equal "Peter Markou", @form.speaker.name
    assert_equal "Developer", @form.speaker.occupation
    assert_equal "Ruby OOP", @form.speaker.presentations[0].topic
    assert_equal "1h", @form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", @form.speaker.presentations[1].topic
    assert_equal "1h", @form.speaker.presentations[1].duration
    assert_equal 2, @form.speaker.presentations.size
  end

  test "main form validates itself" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Petros Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
        }
      }
    }

    @form.submit(params)

    assert @form.valid?

    params = {
      name: nil,
      city: nil,

      speaker_attributes: {
        name: nil,
        occupation: nil,

        presentations_attributes: {
          "0" => { topic: nil, duration: nil },
          "1" => { topic: nil, duration: nil },
        }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_includes @form.errors.messages[:city], "can't be blank"
    assert_equal 2, @form.errors.messages[:name].size
    assert_includes @form.errors.messages[:occupation], "can't be blank"
    assert_includes @form.errors.messages[:topic], "can't be blank"
    assert_equal 2, @form.errors.messages[:topic].size
    assert_includes @form.errors.messages[:duration], "can't be blank"
    assert_equal 2, @form.errors.messages[:duration].size
  end

  test "main form validates the models" do
    conference = conferences(:ruby)
    params = {
      name: conference.name,
      city: "Athens",

      speaker_attributes: {
        name: conference.speaker.name,
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
        }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_equal 2, @form.errors.messages[:name].size
  end

  test "presentations sub-form raises error if records exceed the allowed number" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Petros Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
          "2" => { topic: "Ruby Blocks", duration: "1h" },
        }
      }
    }

    #exception = assert_raises(TooManyRecords) { @form.submit(params) }
    #assert_equal "Maximum 2 records are allowed. Got 3 records instead.", exception.message
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Petros Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
        }
      }
    }

    @form.submit(params)

    assert_difference(['Conference.count', 'Speaker.count']) do
      @form.save
    end

    assert_equal "Euruco", @form.name
    assert_equal "Athens", @form.city
    assert_equal "Petros Markou", @form.speaker.name
    assert_equal "Developer", @form.speaker.occupation
    assert_equal "Ruby OOP", @form.speaker.presentations[0].topic
    assert_equal "1h", @form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", @form.speaker.presentations[1].topic
    assert_equal "1h", @form.speaker.presentations[1].duration
    assert_equal 2, @form.speaker.presentations.size

    assert @form.persisted?
    assert @form.speaker.persisted?
    @form.speaker.presentations.each do |presentation|
      assert presentation.persisted?
    end
  end

  test "main form saves its model and dynamically added models in nested sub-forms" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Petros Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
          "1404292088779" => { topic: "Ruby Blocks", duration: "1h" }
        }
      }
    }

    @form.submit(params)

    assert_difference(['Conference.count', 'Speaker.count']) do
      @form.save
    end

    assert_equal "Euruco", @form.name
    assert_equal "Athens", @form.city
    assert_equal "Petros Markou", @form.speaker.name
    assert_equal "Developer", @form.speaker.occupation
    assert_equal "Ruby OOP", @form.speaker.presentations[0].topic
    assert_equal "1h", @form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", @form.speaker.presentations[1].topic
    assert_equal "1h", @form.speaker.presentations[1].duration
    assert_equal "Ruby Blocks", @form.speaker.presentations[2].topic
    assert_equal "1h", @form.speaker.presentations[2].duration
    assert_equal 3, @form.speaker.presentations.size

    assert @form.persisted?
    assert @form.speaker.persisted?
    @form.speaker.presentations.each do |presentation|
      assert presentation.persisted?
    end
  end

  test "main form updates its model and the models in nested sub-forms" do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    params = {
      name: "GoGaruco",
      city: "Golden State",

      speaker_attributes: {
        name: "John Doe",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
        }
      }
    }

    form.submit(params)

    assert_difference(['Conference.count', 'Speaker.count', 'Presentation.count'], 0) do
      form.save
    end

    assert_equal "GoGaruco", form.name
    assert_equal "Golden State", form.city
    assert_equal "John Doe", form.speaker.name
    assert_equal "Developer", form.speaker.occupation
    assert_equal "Rails Patterns", form.speaker.presentations[0].topic
    assert_equal "1h", form.speaker.presentations[0].duration
    assert_equal "Rails OOP", form.speaker.presentations[1].topic
    assert_equal "1h", form.speaker.presentations[1].duration
    assert_equal 2, form.speaker.presentations.size

    assert form.persisted?
  end

  test "main form updates its model and saves dynamically added models in nested sub-forms" do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    params = {
      name: "GoGaruco",
      city: "Golden State",

      speaker_attributes: {
        name: "John Doe",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
          "1404292088779" => { topic: "Rails Migrations", duration: "1h" }
        }
      }
    }

    form.submit(params)

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "GoGaruco", form.name
    assert_equal "Golden State", form.city
    assert_equal "John Doe", form.speaker.name
    assert_equal "Developer", form.speaker.occupation
    assert_equal "Rails Patterns", form.speaker.presentations[0].topic
    assert_equal "1h", form.speaker.presentations[0].duration
    assert_equal "Rails OOP", form.speaker.presentations[1].topic
    assert_equal "1h", form.speaker.presentations[1].duration
    assert_equal "Rails Migrations", form.speaker.presentations[2].topic
    assert_equal "1h", form.speaker.presentations[2].duration
    assert_equal 3, form.speaker.presentations.size

    assert form.persisted?
  end

  test "main form deletes models in nested sub-forms" do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    params = {
      name: "GoGaruco",
      city: "Golden State",

      speaker_attributes: {
        name: "John Doe",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id, "_destroy" => "1" },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
        }
      }
    }

    form.submit(params)

    assert conference.speaker.presentations[1].marked_for_destruction?

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "GoGaruco", form.name
    assert_equal "Golden State", form.city
    assert_equal "John Doe", form.speaker.name
    assert_equal "Developer", form.speaker.occupation
    assert_equal "Rails Patterns", form.speaker.presentations[0].topic
    assert_equal "1h", form.speaker.presentations[0].duration
    assert_equal 1, form.speaker.presentations.size

    assert form.persisted?
    form.speaker.presentations.each do |presentation|
      assert presentation.persisted?
    end
  end

  test "main form deletes and adds models in nested sub-forms" do
    conference = conferences(:ruby)
    form = ConferenceForm.new(conference)
    params = {
      name: "GoGaruco",
      city: "Golden State",

      speaker_attributes: {
        name: "John Doe",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id, "_destroy" => "1" },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
          "1404292088779" => { topic: "Rails Testing", duration: "2h" }
        }
      }
    }

    form.submit(params)

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "GoGaruco", form.name
    assert_equal "Golden State", form.city
    assert_equal "John Doe", form.speaker.name
    assert_equal "Developer", form.speaker.occupation
    assert_equal "Rails Patterns", form.speaker.presentations[0].topic
    assert_equal "1h", form.speaker.presentations[0].duration
    assert_equal "Rails Testing", form.speaker.presentations[1].topic
    assert_equal "2h", form.speaker.presentations[1].duration
    assert_equal 2, form.speaker.presentations.size

    assert form.persisted?
    form.speaker.presentations.each do |presentation|
      assert presentation.persisted?
    end
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :speaker_attributes=
  end

  test "speaker sub-form responds to writer method" do
    assert_respond_to @form.speaker, :presentations_attributes=
  end
end
