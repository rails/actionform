require 'test_helper'

class TwoNestedCollectionsFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :surveys, :questions, :answers

  def setup
    @survey = Survey.new
    @form = SurveyForm.new(@survey)
    @model = @form
  end

  test "main form provides getter method for questions collection form" do
    questions_form = @form.forms.first

    assert_instance_of ActiveForm::FormCollection, questions_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    questions_form = @form.forms.first

    assert questions_form.represents?("questions")
    assert_not questions_form.represents?("question")
  end

  test "main form provides getter method for collection objects" do
    assert_respond_to @form, :questions

    questions = @form.questions

    questions.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Question, form.model
    end
  end

  test "questions sub-form contains association name and parent model" do
    questions_form = @form.forms.first

    assert_equal :questions, questions_form.association_name
    assert_equal 1, questions_form.records
    assert_equal @survey, questions_form.parent
  end

  test "each questions_form declares a answers FormCollection" do
    questions_form = @form.forms.first

    assert_equal 1, questions_form.forms.size

    @form.questions.each do |question_form|
      assert_instance_of ActiveForm::Form, question_form
      assert_instance_of Question, question_form.model
      assert_equal 1, questions_form.forms.size

      answers = question_form.answers

      answers.each do |answer_form|
        assert_instance_of ActiveForm::Form, answer_form
        assert_instance_of Answer, answer_form.model
      end
    end
  end

  test "main form initializes the number of records specified" do
    questions_form = @form.forms.first

    assert_respond_to questions_form, :models
    assert_equal 1, questions_form.models.size

    questions_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Question, form.model
      assert_respond_to form, :content
      assert_respond_to form, :content=

      answers_form = form.forms.first

      assert_respond_to answers_form, :models
      assert_equal 2, answers_form.models.size

      answers_form.each do |answer_form|
        assert_instance_of ActiveForm::Form, answer_form
        assert_instance_of Answer, answer_form.model
        assert_respond_to answer_form, :content
        assert_respond_to answer_form, :content=
      end
    end

    assert_equal 1, @form.model.questions.size
  end

  test "main form fetches parent and association objects" do
    survey = surveys(:programming)

    form = SurveyForm.new(survey)

    assert_equal survey.name, form.name
    assert_equal 1, form.questions.size
    assert_equal survey.questions[0], form.questions[0].model
    assert_equal survey.questions[0].answers[0], form.questions[0].answers[0].model
    assert_equal survey.questions[0].answers[1], form.questions[0].answers[1].model
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Programming languages",

      questions_attributes: {
        "0" => {
          content: "Which language allows closures?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "CSharp Programming Language" },
          }
        },
      }
    }

    @form.submit(params)

    assert_equal "Programming languages", @form.name
    assert_equal "Which language allows closures?", @form.questions[0].content
    assert_equal "Ruby Programming Language", @form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", @form.questions[0].answers[1].content
    assert_equal 1, @form.questions.size
  end

  test "main form validates itself" do
    params = {
      name: "Programming languages",

      questions_attributes: {
        "0" => {
          content: "Which language allows closures?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "CSharp Programming Language" },
          }
        },
      }
    }

    @form.submit(params)

    assert @form.valid?

    params = {
      name: nil,

      questions_attributes: {
        "0" => {
          content: nil,

          answers_attributes: {
            "0" => { content: nil },
            "1" => { content: nil },
          }
        },
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_includes @form.errors.messages[:content], "can't be blank"
  end

  test "main form validates the model" do
    params = {
      name: surveys(:programming).name,

      questions_attributes: {
        "0" => {
          content: "Which language allows closures?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "CSharp Programming Language" },
          }
        },
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "has already been taken"
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Programming languages",

      questions_attributes: {
        "0" => {
          content: "Which language allows closures?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "CSharp Programming Language" },
          }
        },
      }
    }

    @form.submit(params)

    assert_difference('Survey.count') do
      @form.save
    end

    assert_equal "Programming languages", @form.name
    assert_equal "Which language allows closures?", @form.questions[0].content
    assert_equal "Ruby Programming Language", @form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", @form.questions[0].answers[1].content
    assert_equal 1, @form.questions.size

    assert @form.persisted?
    @form.questions.each do |question|
      assert question.persisted?
      assert_equal 2, question.answers.size

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end
  end

  test "main form saves its model and dynamically added models in nested sub-forms" do
    params = {
      name: "Programming languages",

      questions_attributes: {
        "0" => {
          content: "Which language allows closures?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "CSharp Programming Language" }
          }
        },
        "1404292088779" => {
          content: "Which language allows blocks?",

          answers_attributes: {
            "0" => { content: "Ruby Programming Language" },
            "1" => { content: "C Programming Language" }
          }
        }
      }
    }

    @form.submit(params)

    assert_difference('Survey.count') do
      @form.save
    end

    assert_equal "Programming languages", @form.name
    assert_equal "Which language allows closures?", @form.questions[0].content
    assert_equal "Ruby Programming Language", @form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", @form.questions[0].answers[1].content
    assert_equal "Which language allows blocks?", @form.questions[1].content
    assert_equal "Ruby Programming Language", @form.questions[1].answers[0].content
    assert_equal "C Programming Language", @form.questions[1].answers[1].content
    assert_equal 2, @form.questions.size

    assert @form.persisted?
    @form.questions.each do |question|
      assert question.persisted?
      assert_equal 2, question.answers.size

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end
  end

  test "main form updates its model and the models in nested sub-forms" do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = {
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

    form.submit(params)

    assert_difference('Survey.count', 0) do
      form.save
    end

    assert_equal "Native languages", form.name
    assert_equal "Which language is spoken in England?", form.questions[0].content
    assert_equal "The Latin Language", form.questions[0].answers[0].content
    assert_equal "The English Language", form.questions[0].answers[1].content
    assert_equal 1, form.questions.size
  end

  test "main form updates its model and saves dynamically added models in nested sub-forms" do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = {
      name: "Native languages",

      questions_attributes: {
        "0" => {
          content: "Which language is spoken in England?",
          id: questions(:one).id,

          answers_attributes: {
            "0" => { content: "The English Language", id: answers(:ruby).id },
            "1" => { content: "The Latin Language", id: answers(:cs).id }
          }
        },
        "1404292088779" => {
          content: "Which language is spoken in America?",

          answers_attributes: {
            "0" => { content: "The English Language" },
            "1" => { content: "The American Language" }
          }
        }
      }
    }

    form.submit(params)

    assert_difference('Survey.count', 0) do
      form.save
    end

    assert_equal "Native languages", form.name
    assert_equal "Which language is spoken in England?", form.questions[0].content
    assert_equal "The Latin Language", form.questions[0].answers[0].content
    assert_equal "The English Language", form.questions[0].answers[1].content
    assert_equal "Which language is spoken in America?", form.questions[1].content
    assert_equal "The English Language", form.questions[1].answers[0].content
    assert_equal "The American Language", form.questions[1].answers[1].content
    assert_equal 2, form.questions.size
  end

  test "main form deletes models in nested sub-forms" do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = {
      name: "Native languages",

      questions_attributes: {
        "0" => {
          content: "Which language is spoken in England?",
          id: questions(:one).id,

          answers_attributes: {
            "0" => { content: "The English Language", id: answers(:ruby).id },
            "1" => { content: "The Latin Language", id: answers(:cs).id, "_destroy" => "1" },
          }
        }
      }
    }

    form.submit(params)

    assert survey.questions[0].answers[0].marked_for_destruction?

    assert_difference('Survey.count', 0) do
      form.save
    end

    assert_equal "Native languages", form.name
    assert_equal "Which language is spoken in England?", form.questions[0].content
    assert_equal "The English Language", form.questions[0].answers[0].content
    assert_equal 1, form.questions.size
    assert_equal 1, form.questions[0].answers.size
  end

  test "main form deletes and adds models in nested sub-forms" do
    survey = surveys(:programming)
    form = SurveyForm.new(survey)
    params = {
      name: "Native languages",

      questions_attributes: {
        "0" => {
          content: "Which language is spoken in England?",
          id: questions(:one).id,
          "_destroy" => "1",

          answers_attributes: {
            "0" => { content: "The English Language", id: answers(:ruby).id },
            "1" => { content: "The Latin Language", id: answers(:cs).id }
          }
        },
        "1404292088779" => {
          content: "Which language is spoken in America?",

          answers_attributes: {
            "0" => { content: "The English Language" },
            "1" => { content: "The American Language" },
            "1404292088777" => { content: "The French Language" }
          }
        }
      }
    }

    form.submit(params)

    assert_difference('Survey.count', 0) do
      form.save
    end

    assert_equal "Native languages", form.name
    assert_equal "Which language is spoken in America?", form.questions[0].content
    assert_equal "The English Language", form.questions[0].answers[0].content
    assert_equal "The American Language", form.questions[0].answers[1].content
    assert_equal "The French Language", form.questions[0].answers[2].content
    assert_equal 1, form.questions.size
    assert_equal 3, form.questions[0].answers.size
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :questions_attributes=
  end

  test "questions form responds to writer method" do
    @form.questions.each do |question_form|
      assert_respond_to question_form, :answers_attributes=
    end
  end
end