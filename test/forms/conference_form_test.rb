require 'test_helper'

class ConferenceFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  include ActionDispatch::TestProcess

  fixtures :conferences, :speakers, :presentations

  def setup
    @conference = Conference.new
    @form = ConferenceForm.new(@conference)
    @model = @form
  end

  test "contains getter for presentations sub-form" do
    assert_respond_to @form.speaker, :presentations

    presentations_form = @form.speaker.forms.first
    assert_instance_of ActionForm::FormCollection, presentations_form
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
      assert_instance_of ActionForm::Form, form
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
      assert_instance_of ActionForm::Form, form
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
    @form.submit(default_params)

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
    @form.submit(merge_params(speaker_attributes: { name: 'Unique Name' }))
    assert @form.valid?
  end

  test "validation with empty params" do
    @form.submit({})

    assert_not @form.valid?

    assert_includes @form.errors[:name], "can't be blank"
    assert_equal 1, @form.errors[:name].size
    assert_includes @form.errors[:city], "can't be blank"
    assert_equal 1, @form.errors[:city].size

    assert_includes @form.errors["speaker.name"], "can't be blank"

    assert_includes @form.errors["speaker.occupation"], "can't be blank"

    assert_includes @form.errors["speaker.presentations.topic"], "can't be blank"
    assert_equal 2, @form.errors["speaker.presentations.topic"].size

    assert_includes @form.errors["speaker.presentations.duration"], "can't be blank"
    assert_equal 2, @form.errors["speaker.presentations.duration"].size
  end

  test "main form validates the models" do
    @form.submit(speaker_attributes: { name: conferences(:ruby).speaker.name })

    assert_not @form.valid?

    assert_includes @form.errors["name"], "can't be blank"
    assert_includes @form.errors["speaker.name"], "has already been taken"
  end

  test "presentations sub-form raises error if records exceed the allowed number" do
    skip "TODO"
    {
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
    @form.submit(merge_params(speaker_attributes: { name: 'Petros Markou' }))

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
    @form.submit(merge_params(speaker_attributes: {
      name: "Petros Markou",
      presentations_attributes: {
        "1404292088779" => { topic: "Ruby Blocks", duration: "1h" }
      }
    }))

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
    form.submit(merge_params(
      speaker_attributes: {
        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id }
        }
      }
    ))

    assert_difference(['Conference.count', 'Speaker.count', 'Presentation.count'], 0) do
      form.save
    end

    assert_equal "Euruco", form.name
    assert_equal "Athens", form.city
    assert_equal "Peter Markou", form.speaker.name
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
    form.submit(merge_params(
      speaker_attributes: {
        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
          "1404292088779" => { topic: "Rails Migrations", duration: "1h" }
        }
      }
    ))

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "Euruco", form.name
    assert_equal "Athens", form.city
    assert_equal "Peter Markou", form.speaker.name
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
    form.submit(merge_params(
      speaker_attributes: {
        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id, "_destroy" => "1" },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id }
        }
      }
    ))

    assert conference.speaker.presentations[1].marked_for_destruction?

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "Euruco", form.name
    assert_equal "Athens", form.city
    assert_equal "Peter Markou", form.speaker.name
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
    form.submit(merge_params(
      speaker_attributes: {
        presentations_attributes: {
          "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id, "_destroy" => "1" },
          "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id },
          "1404292088779" => { topic: "Rails Testing", duration: "2h" }
        }
      }
    ))

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      form.save
    end

    assert_equal "Euruco", form.name
    assert_equal "Athens", form.city
    assert_equal "Peter Markou", form.speaker.name
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

  test "accepts file" do
    @form.submit(merge_params(
      photo: fixture_file_upload('demo.txt', 'text/plain'),
      speaker_attributes: { name: 'Unique Name' }
    ))

    assert @form.valid?
    assert_equal @form.photo, 'demo.txt'
  end

  private
    def merge_params(params)
      default_params.deep_merge(params)
    end

    def default_params
      @default_params ||= {
        name: "Euruco", city: "Athens",

        speaker_attributes: {
          name: "Peter Markou", occupation: "Developer",

          presentations_attributes: {
            "0" => { topic: "Ruby OOP", duration: "1h" },
            "1" => { topic: "Ruby Closures", duration: "1h" },
          }
        }
      }
    end
end
