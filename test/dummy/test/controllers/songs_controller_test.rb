require 'test_helper'

class SongsControllerTest < ActionController::TestCase
  fixtures :songs, :artists, :producers

  setup do
    @song = songs(:lockdown)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:songs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create song" do
    assert_difference(['Song.count', 'Artist.count', 'Producer.count']) do
      params = {
        song: {
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
      }
      post :create, wrapped_params(params)
    end

    song_form = assigns(:song_form)

    assert song_form.valid?
    assert_redirected_to song_path(song_form)

    assert_equal "Diamonds", song_form.title
    assert_equal "360", song_form.length

    assert_equal "Karras", song_form.artist.name

    assert_equal "Phoebos", song_form.artist.producer.name
    assert_equal "MADog", song_form.artist.producer.studio

    assert song_form.artist.persisted?
    assert song_form.artist.producer.persisted?

    assert_equal "Song: Diamonds was successfully created.", flash[:notice]
  end

  test "should not create song with invalid params" do
    assert_difference(['Song.count', 'Artist.count', 'Producer.count'], 0) do
      params = {
        song: {
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
      }
      post :create, wrapped_params(params)
    end

    song_form = assigns(:song_form)

    assert_not song_form.valid?

    assert_includes song_form.errors[:title], "can't be blank"
    assert_includes song_form.errors[:length], "can't be blank"

    assert_includes song_form.errors["artist.name"], "can't be blank"
    assert_includes song_form.artist.errors[:name], "can't be blank"

    assert_includes song_form.artist.producer.errors[:name], "can't be blank"
    assert_includes song_form.artist.producer.errors[:studio], "can't be blank"

    assert_includes song_form.errors["artist.producer.name"], "can't be blank"
    assert_includes song_form.errors["artist.producer.studio"], "can't be blank"
  end

  test "should show song" do
    get :show, wrapped_params(id: @song)
    assert_response :success
  end

  test "should get edit" do
    get :edit, wrapped_params(id: @song)
    assert_response :success
  end

  test "should update song" do
    assert_difference(['Song.count', 'Artist.count', 'Producer.count'], 0) do
      params = {
        id: @song, song: {
          title: "Run this town",
          length: "355",

          artist_attributes: {
            name: "Rihanna",

            producer_attributes: {
              name: "Eminem",
              studio: "Marshall"
            }
          }
        }
      }
      patch :update, wrapped_params(params)
    end

    song_form = assigns(:song_form)

    assert_redirected_to song_path(song_form)

    assert_equal "Run this town", song_form.title
    assert_equal "355", song_form.length

    assert_equal "Rihanna", song_form.artist.name

    assert_equal "Eminem", song_form.artist.producer.name
    assert_equal "Marshall", song_form.artist.producer.studio

    assert_equal "Song: Run this town was successfully updated.", flash[:notice]
  end

  test "should destroy song" do
    assert_difference('Song.count', -1) do
      delete :destroy, wrapped_params(id: @song)
    end

    assert_redirected_to songs_path
  end
end
