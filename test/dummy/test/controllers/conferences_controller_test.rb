require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  fixtures :conferences, :speakers, :presentations

  setup do
    @conference = conferences(:ruby)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:conferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      params = {
        conference: {
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
      }
      post :create, wrapped_params(params)
    end

    conference_form = assigns(:conference_form)

    assert conference_form.valid?
    assert_redirected_to conference_path(conference_form)

    assert_equal "Euruco", conference_form.name
    assert_equal "Athens", conference_form.city

    assert_equal "Petros Markou", conference_form.speaker.name
    assert_equal "Developer", conference_form.speaker.occupation

    assert_equal "Ruby OOP", conference_form.speaker.presentations[0].topic
    assert_equal "1h", conference_form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", conference_form.speaker.presentations[1].topic
    assert_equal "1h", conference_form.speaker.presentations[1].duration

    assert conference_form.speaker.persisted?
    conference_form.speaker.presentations.each do |presentation|
      presentation.persisted?
    end

    assert_equal "Conference: #{conference_form.name} was successfully created.", flash[:notice]
  end

  test "should create dynamically added presentation to speaker" do
    assert_difference('Conference.count') do
      params = {
        conference: {
          name: "Euruco",
          city: "Athens",

          speaker_attributes: {
            name: "Petros Markou",
            occupation: "Developer",

            presentations_attributes: {
              "0" => { topic: "Ruby OOP", duration: "1h" },
              "1" => { topic: "Ruby Closures", duration: "1h" },
              "12312" => { topic: "Ruby Metaprogramming", duration: "2h" }
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    conference_form = assigns(:conference_form)

    assert conference_form.valid?
    assert_redirected_to conference_path(conference_form)

    assert_equal "Euruco", conference_form.name
    assert_equal "Athens", conference_form.city

    assert_equal "Petros Markou", conference_form.speaker.name
    assert_equal "Developer", conference_form.speaker.occupation

    assert_equal 3, conference_form.speaker.presentations.size

    assert_equal "Ruby OOP", conference_form.speaker.presentations[0].topic
    assert_equal "1h", conference_form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", conference_form.speaker.presentations[1].topic
    assert_equal "1h", conference_form.speaker.presentations[1].duration
    assert_equal "Ruby Metaprogramming", conference_form.speaker.presentations[2].topic
    assert_equal "2h", conference_form.speaker.presentations[2].duration

    assert conference_form.speaker.persisted?
    conference_form.speaker.presentations.each do |presentation|
      presentation.persisted?
    end

    assert_equal "Conference: #{conference_form.name} was successfully created.", flash[:notice]
  end

  test "should not create conference with invalid params" do
    conference = conferences(:ruby)

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      params = {
        conference: {
          name: conference.name,
          city: nil,

          speaker_attributes: {
            name: conference.speaker.name,
            occupation: "Developer",

            presentations_attributes: {
              "0" => { topic: nil, duration: "1h" },
              "1" => { topic: "Ruby Closures", duration: nil },
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    conference_form = assigns(:conference_form)

    assert_not conference_form.valid?

    assert_includes conference_form.errors.messages[:name], "has already been taken"
    assert_includes conference_form.errors.messages[:city], "can't be blank"

    assert_includes conference_form.speaker.errors.messages[:name], "has already been taken"

    assert_includes conference_form.speaker.presentations[0].errors.messages[:topic], "can't be blank"
    assert_includes conference_form.speaker.presentations[1].errors.messages[:duration], "can't be blank"
  end

  test "should show conference" do
    get :show, wrapped_params(id: @conference)
    assert_response :success
  end

  test "should get edit" do
    get :edit, wrapped_params(id: @conference)
    assert_response :success
  end

  test "should update conference" do
    assert_difference('Conference.count', 0) do
      params = {
        id: @conference, conference: {
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
      }
      patch :update, wrapped_params(params)
    end

    conference_form = assigns(:conference_form)

    assert_redirected_to conference_path(conference_form)

    assert_equal "GoGaruco", conference_form.name
    assert_equal "Golden State", conference_form.city

    assert_equal "John Doe", conference_form.speaker.name
    assert_equal "Developer", conference_form.speaker.occupation

    assert_equal "Rails Patterns", conference_form.speaker.presentations[0].topic
    assert_equal "1h", conference_form.speaker.presentations[0].duration
    assert_equal "Rails OOP", conference_form.speaker.presentations[1].topic
    assert_equal "1h", conference_form.speaker.presentations[1].duration

    assert_equal "Conference: #{conference_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy dynamically removed presentation from speaker" do
    assert_difference('Conference.count', 0) do
      params = {
        id: @conference, conference: {
          name: "GoGaruco",
          city: "Golden State",

          speaker_attributes: {
            name: "John Doe",
            occupation: "Developer",

            presentations_attributes: {
              "0" => { topic: "Rails OOP", duration: "1h", id: presentations(:ruby_oop).id },
              "1" => { topic: "Rails Patterns", duration: "1h", id: presentations(:ruby_closures).id, _destroy: "1" },
            }
          }
        }
      }
      patch :update, wrapped_params(params)
    end

    conference_form = assigns(:conference_form)

    assert_redirected_to conference_path(conference_form)

    assert_equal "GoGaruco", conference_form.name
    assert_equal "Golden State", conference_form.city

    assert_equal "John Doe", conference_form.speaker.name
    assert_equal "Developer", conference_form.speaker.occupation

    assert_equal "Rails OOP", conference_form.speaker.presentations[0].topic
    assert_equal "1h", conference_form.speaker.presentations[0].duration

    assert_equal 1, conference_form.speaker.presentations.size

    assert_equal "Conference: #{conference_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy conference" do
    assert_difference('Conference.count', -1) do
      delete :destroy, wrapped_params(id: @conference)
    end

    assert_redirected_to conferences_path
  end
end
