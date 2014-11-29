require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  fixtures :assignments, :tasks

  setup do
    @assignment = assignments(:yard)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assignment" do
    assert_difference('Assignment.count') do
      post :create, assignment: {
        name: "Life",

        tasks_attributes: {
          "0" => { name: "Eat" },
          "1" => { name: "Pray" },
          "2" => { name: "Love" },
        }
      }
    end

    assignment_form = assigns(:assignment_form)

    assert assignment_form.valid?
    assert_redirected_to assignment_path(assignment_form)

    assert_equal "Life", assignment_form.name

    assert_equal "Eat", assignment_form.tasks[0].name
    assert_equal "Pray", assignment_form.tasks[1].name
    assert_equal "Love", assignment_form.tasks[2].name

    assignment_form.tasks.each do |task_form|
      assert task_form.persisted?
    end

    assert_equal "Assignment: Life was successfully created.", flash[:notice]
  end

  test "should not create assignment with invalid params" do
    assignment = assignments(:yard)

    assert_difference('Assignment.count', 0) do
      post :create, assignment: {
        name: assignment.name,

        tasks_attributes: {
          "0" => { name: nil },
          "1" => { name: nil },
          "2" => { name: nil },
        }
      }
    end

    assignment_form = assigns(:assignment_form)

    assert_not assignment_form.valid?
    assert_includes assignment_form.errors.messages[:name], "has already been taken"

    assignment_form.tasks.each do |task_form|
      assert_includes task_form.errors.messages[:name], "can't be blank"
    end
  end

  test "should show assignment" do
    get :show, id: @assignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @assignment
    assert_response :success
  end

  test "should update assignment" do
    assert_difference('Assignment.count', 0) do
      patch :update, id: @assignment, assignment: {
        name: "Car service",

        tasks_attributes: {
          "0" => { name: "Wash tires", id: tasks(:rake).id },
          "1" => { name: "Clean inside", id: tasks(:paint).id },
          "2" => { name: "Check breaks", id: tasks(:clean).id },
        }
      }
    end

    assignment_form = assigns(:assignment_form)

    assert_redirected_to assignment_path(assignment_form)

    assert_equal "Car service", assignment_form.name

    assert_equal "Wash tires", assignment_form.tasks[0].name
    assert_equal "Clean inside", assignment_form.tasks[1].name
    assert_equal "Check breaks", assignment_form.tasks[2].name

    assert_equal "Assignment: Car service was successfully updated.", flash[:notice]
  end

  test "should destroy assignment" do
    assert_difference('Assignment.count', -1) do
      delete :destroy, id: @assignment
    end

    assert_redirected_to assignments_path
  end
end
