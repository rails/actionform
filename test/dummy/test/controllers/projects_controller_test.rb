require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects

  setup do
    @project = projects(:yard)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, wrapped_params(project: { description: @project.description, name: @project.name })
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    get :show, wrapped_params(id: @project)
    assert_response :success
  end

  test "should get edit" do
    get :edit, wrapped_params(id: @project)
    assert_response :success
  end

  test "should update project" do
    patch :update, wrapped_params(id: @project, project: { description: @project.description, name: @project.name })
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete :destroy, wrapped_params(id: @project)
    end

    assert_redirected_to projects_path
  end
end
