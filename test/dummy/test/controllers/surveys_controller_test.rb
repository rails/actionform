require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  fixtures :surveys, :questions, :answers

  setup do
    @survey = surveys(:programming)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:surveys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey" do
    assert_difference('Survey.count') do
      params = {
        survey: {
          name: "Programming languages",

          questions_attributes: {
            "0" => {
              content: "Which language allows closures?",

              answers_attributes: {
                "0" => { content: "Ruby Programming Language" },
                "1" => { content: "CSharp Programming Language" },
              }
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert survey_form.valid?
    assert_redirected_to survey_path(assigns(:survey_form))

    assert_equal "Programming languages", survey_form.name

    assert_equal "Which language allows closures?", survey_form.questions[0].content

    assert_equal "Ruby Programming Language", survey_form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", survey_form.questions[0].answers[1].content

    survey_form.questions.each do |question|
      assert question.persisted?

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end

    assert_equal "Survey: #{survey_form.name} was successfully created.", flash[:notice]
  end

  test "should create dynamically added question to a survey" do
    assert_difference('Survey.count') do
      params = {
        survey: {
          name: "Programming languages",

          questions_attributes: {
            "0" => {
              content: "Which language allows closures?",

              answers_attributes: {
                "0" => { content: "Ruby Programming Language" },
                "1" => { content: "CSharp Programming Language" },
              }
            },

            "12343" => {
              content: "Which language allows objects?",

              answers_attributes: {
                "0" => { content: "Ruby Programming Language" },
                "1" => { content: "C Programming Language" },
              }
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert survey_form.valid?
    assert_redirected_to survey_path(assigns(:survey_form))

    assert_equal "Programming languages", survey_form.name

    assert_equal 2, survey_form.questions.size

    assert_equal "Which language allows closures?", survey_form.questions[0].content

    assert_equal "Ruby Programming Language", survey_form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", survey_form.questions[0].answers[1].content

    assert_equal "Which language allows objects?", survey_form.questions[1].content

    assert_equal "Ruby Programming Language", survey_form.questions[1].answers[0].content
    assert_equal "C Programming Language", survey_form.questions[1].answers[1].content

    survey_form.questions.each do |question|
      assert question.persisted?

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end

    assert_equal "Survey: #{survey_form.name} was successfully created.", flash[:notice]
  end

  test "should create dynamically added answer to a question" do
    assert_difference('Survey.count') do
      params = {
        survey: {
          name: "Programming languages",

          questions_attributes: {
            "0" => {
              content: "Which language allows closures?",

              answers_attributes: {
                "0" => { content: "Ruby Programming Language" },
                "1" => { content: "CSharp Programming Language" },
                "12322" => { content: "C Programming Language" }
              }
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert survey_form.valid?
    assert_redirected_to survey_path(assigns(:survey_form))

    assert_equal "Programming languages", survey_form.name

    assert_equal "Which language allows closures?", survey_form.questions[0].content

    assert_equal 3, survey_form.questions[0].answers.size

    assert_equal "Ruby Programming Language", survey_form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", survey_form.questions[0].answers[1].content
    assert_equal "C Programming Language", survey_form.questions[0].answers[2].content

    survey_form.questions.each do |question|
      assert question.persisted?

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end

    assert_equal "Survey: #{survey_form.name} was successfully created.", flash[:notice]
  end

  test "should not create survey with invalid params" do
    assert_difference('Survey.count', 0) do
      params = {
        survey: {
          name: surveys(:programming).name,

          questions_attributes: {
            "0" => {
              content: nil,

              answers_attributes: {
                "0" => { content: "Ruby Programming Language" },
                "1" => { content: nil },
              }
            }
          }
        }
      }
      post :create, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert_not survey_form.valid?

    assert_includes survey_form.errors.messages[:name], "has already been taken"

    assert_includes survey_form.questions[0].errors.messages[:content], "can't be blank"

    assert_includes survey_form.questions[0].answers[1].errors.messages[:content], "can't be blank"
  end

  test "should show survey" do
    get :show, wrapped_params(id: @survey)
    assert_response :success
  end

  test "should get edit" do
    get :edit, wrapped_params(id: @survey)
    assert_response :success
  end

  test "should update survey" do
    assert_difference('Survey.count', 0) do
      params = {
        id: @survey, survey: {
          name: "Native languages",

          questions_attributes: {
            "0" => {
              content: "Which language is spoken in England?",
              id: questions(:one).id,

              answers_attributes: {
                "0" => { content: "The English Language", id: answers(:ruby).id },
                "1" => { content: "The Latin Language", id: answers(:cs).id },
              }
            },
          }
        }
      }
      patch :update, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert_redirected_to survey_path(survey_form)

    assert_equal "Native languages", survey_form.name

    assert_equal "Which language is spoken in England?", survey_form.questions[0].content

    assert_equal "The Latin Language", survey_form.questions[0].answers[0].content
    assert_equal "The English Language", survey_form.questions[0].answers[1].content

    assert_equal "Survey: #{survey_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy dynamically removed question from survey" do
    survey = Survey.new(name: "Oral languages")
    survey.questions << Question.new(content: "Which language is spoken in England?")
    survey.questions << Question.new(content: "Which language is spoken in America?")
    survey.questions[0].answers << Answer.new(content: "English")
    survey.questions[0].answers << Answer.new(content: "Latin")
    survey.questions[1].answers << Answer.new(content: "English")
    survey.questions[1].answers << Answer.new(content: "American")
    survey.save

    assert_difference('Survey.count', 0) do
      params = {
        id: survey, survey: {
          name: "Native languages",

          questions_attributes: {
            "0" => {
              content: "Which language is spoken in England?",
              id: survey.questions[0].id,

              answers_attributes: {
                "0" => { content: "The English Language", id: survey.questions[0].answers[0].id },
                "1" => { content: "The Latin Language", id: survey.questions[0].answers[1].id },
              }
            },

            "1" => {
              content: "Which language is spoken in America?",
              id: survey.questions[1].id,
              _destroy: "1",

              answers_attributes: {
                "0" => { content: "The English Language", id: survey.questions[1].answers[0].id },
                "1" => { content: "The American Language", id: survey.questions[1].answers[1].id },
              }
            }
          }
        }
      }
      patch :update, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert_redirected_to survey_path(survey_form)

    assert_equal "Native languages", survey_form.name

    assert_equal "Which language is spoken in England?", survey_form.questions[0].content

    assert_equal 1, survey_form.questions.size

    assert_equal "The English Language", survey_form.questions[0].answers[0].content
    assert_equal "The Latin Language", survey_form.questions[0].answers[1].content

    assert_equal "Survey: #{survey_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy dynamically removed answer from question" do
    survey = Survey.new(name: "Oral languages")
    survey.questions << Question.new(content: "Which language is spoken in England?")
    survey.questions << Question.new(content: "Which language is spoken in America?")
    survey.questions[0].answers << Answer.new(content: "English")
    survey.questions[0].answers << Answer.new(content: "Latin")
    survey.questions[0].answers << Answer.new(content: "French")
    survey.questions[1].answers << Answer.new(content: "English")
    survey.questions[1].answers << Answer.new(content: "American")
    survey.questions[1].answers << Answer.new(content: "Italian")
    survey.save

    assert_difference('Survey.count', 0) do
      params = {
        id: survey, survey: {
          name: "Native languages",

          questions_attributes: {
            "0" => {
              content: "Which language is spoken in England?",
              id: survey.questions[0].id,

              answers_attributes: {
                "0" => { content: "The English Language", id: survey.questions[0].answers[0].id },
                "1" => { content: "The Latin Language", id: survey.questions[0].answers[1].id },
                "2" => { content: "The French Language", id: survey.questions[0].answers[2].id, _destroy: "1" }
              }
            },

            "1" => {
              content: "Which language is spoken in America?",
              id: survey.questions[1].id,

              answers_attributes: {
                "0" => { content: "The English Language", id: survey.questions[1].answers[0].id },
                "1" => { content: "The American Language", id: survey.questions[1].answers[1].id },
                "2" => { content: "The Italian Language", id: survey.questions[1].answers[2].id, _destroy: "1" }
              }
            }
          }
        }
      }
      patch :update, wrapped_params(params)
    end

    survey_form = assigns(:survey_form)

    assert_redirected_to survey_path(survey_form)

    assert_equal "Native languages", survey_form.name

    assert_equal 2, survey_form.questions.size

    assert_equal "Which language is spoken in England?", survey_form.questions[0].content

    assert_equal 2, survey_form.questions[0].answers.size

    assert_equal "The English Language", survey_form.questions[0].answers[0].content
    assert_equal "The Latin Language", survey_form.questions[0].answers[1].content

    assert_equal "Which language is spoken in America?", survey_form.questions[1].content

    assert_equal 2, survey_form.questions[1].answers.size

    assert_equal "The English Language", survey_form.questions[1].answers[0].content
    assert_equal "The American Language", survey_form.questions[1].answers[1].content

    assert_equal "Survey: #{survey_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy survey" do
    assert_difference('Survey.count', -1) do
      delete :destroy, wrapped_params(id: @survey)
    end

    assert_redirected_to surveys_path
  end
end
