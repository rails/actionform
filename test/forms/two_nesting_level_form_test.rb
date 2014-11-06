require 'test_helper'

class TwoNestingLevelFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :songs, :artists, :producers

  def setup
    @song = Song.new
    @form = SongForm.new(@song)
    @producer_form = @form.artist.producer
    @model = @form
  end

  test "contains getter for producer sub-form" do
    assert_respond_to @form.artist, :producer
    assert_instance_of ActiveForm::Form, @producer_form
  end

  test "producer sub-form contains association name and parent model" do
    assert_equal :producer, @producer_form.association_name
    assert_instance_of Producer, @producer_form.model
    assert_instance_of Artist, @producer_form.parent
  end

  test "producer sub-form initializes models for new parent" do
    assert_equal @form.artist.model.producer, @producer_form.model
    assert @producer_form.model.new_record?
  end

  test "producer sub-form fetches models for existing parent" do
    song = songs(:lockdown)
    form = SongForm.new(song)
    artist_form = form.artist
    producer_form = artist_form.producer

    assert_equal "Love Lockdown", form.title
    assert_equal "350", form.length
    assert form.persisted?

    assert_equal "Kanye West", artist_form.name
    assert artist_form.persisted?

    assert_equal "Jay-Z", producer_form.name
    assert_equal "Ztudio", producer_form.studio
    assert producer_form.persisted?
  end

  test "producer sub-form declares attributes" do
    attributes = [:name, :name=, :studio, :studio=]

    attributes.each do |attribute|
      assert_respond_to @producer_form, attribute
    end
  end

  test "producer sub-form delegates attributes to model" do
    @producer_form.name = "Phoebos"
    @producer_form.studio = "MADog"

    assert_equal "Phoebos", @producer_form.name
    assert_equal "MADog", @producer_form.studio

    assert_equal "Phoebos", @producer_form.model.name
    assert_equal "MADog", @producer_form.model.studio
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      title: "Diamonds",
      length: "360",

      artist_attributes: {
        name: "Karras",

        producer_attributes: {
          name: "Phoebos",
          studio: "MADog"
        }
      }
    }

    @form.submit(params)

    assert_equal "Diamonds", @form.title
    assert_equal "360", @form.length
    assert_equal "Karras", @form.artist.name
    assert_equal "Phoebos", @producer_form.name
    assert_equal "MADog", @producer_form.studio
  end

  test "main form validates itself" do
    params = {
      title: nil,
      length: nil,

      artist_attributes: {
        name: nil,

        producer_attributes: {
          name: nil,
          studio: nil
        }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:title], "can't be blank"
    assert_includes @form.errors.messages[:length], "can't be blank"
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_includes @form.errors.messages[:studio], "can't be blank"

    @form.title = "Diamonds"
    @form.length = "355"
    @form.artist.name = "Karras"
    @producer_form.name = "Phoebos"
    @producer_form.studio = "MADog"

    assert @form.valid?
  end

  test "main form validates the models" do
    song = songs(:lockdown)
    params = {
      title: song.title,
      length: nil,

      artist_attributes: {
        name: song.artist.name,

        producer_attributes: {
          name: song.artist.producer.name,
          studio: song.artist.producer.studio
        }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:title], "has already been taken"
    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_equal 2, @form.errors.messages[:name].size
    assert_includes @form.errors.messages[:studio], "has already been taken"
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      title: "Diamonds",
      length: "360",

      artist_attributes: {
        name: "Karras",

        producer_attributes: {
          name: "Phoebos",
          studio: "MADog"
        }
      }
    }

    @form.submit(params)

    assert_difference(['Song.count', 'Artist.count', 'Producer.count']) do
      @form.save
    end

    assert_equal "Diamonds", @form.title
    assert_equal "360", @form.length
    assert_equal "Karras", @form.artist.name
    assert_equal "Phoebos", @producer_form.name
    assert_equal "MADog", @producer_form.studio

    assert @form.persisted?
    assert @form.artist.persisted?
    assert @producer_form.persisted?
  end

  test "main form updates its model and the models in nested sub-forms" do
    song = songs(:lockdown)
    params = {
      title: "Diamonds",
      length: "360",

      artist_attributes: {
        name: "Karras",

        producer_attributes: {
          name: "Phoebos",
          studio: "MADog"
        }
      }
    }
    form = SongForm.new(song)

    form.submit(params)

    assert_difference(['Song.count', 'Artist.count', 'Producer.count'], 0) do
      form.save
    end

    assert_equal "Diamonds", form.title
    assert_equal "360", form.length
    assert_equal "Karras", form.artist.name
    assert_equal "Phoebos", form.artist.producer.name
    assert_equal "MADog", form.artist.producer.studio

    assert form.persisted?
    assert form.artist.persisted?
    assert form.artist.producer.persisted?
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :artist_attributes=
    assert_respond_to @form.artist, :producer_attributes=
  end
end