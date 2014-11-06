require 'test_helper'

class ProjectFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :projects, :tasks, :people

  def setup
    @project = Project.new
    @form = ProjectForm.new(@project)
    @tasks_form = @form.forms[0]
    @contributors_form = @form.forms[1]
    @project_tags_form = @form.forms[2]
    @owner_form = @form.forms[3]
    @model = @form
  end

  test "project form responds to attributes" do
    attributes = [:name, :name=, :description, :description=]

    attributes.each do |attribute|
      assert_respond_to @form, attribute
    end
  end

  test "declares collection association" do
    assert_respond_to ProjectForm, :association
  end

  test "forms list contains sub-form definitions" do
    assert_equal 4, ProjectForm.forms.size

    tasks_definition = ProjectForm.forms[0]
    contributors_definition = ProjectForm.forms[1]
    project_tags_definition = ProjectForm.forms[2]
    owner_definition = ProjectForm.forms[3]

    assert_equal :tasks, tasks_definition.assoc_name
    assert_equal :contributors, contributors_definition.assoc_name
    assert_equal :project_tags, project_tags_definition.assoc_name
    assert_equal :owner, owner_definition.assoc_name
  end

  test "project form provides getter method for tasks sub-form" do
    assert_instance_of ActiveForm::FormCollection, @tasks_form
  end

  test "project form provides getter method for contributors sub-form" do
    assert_instance_of ActiveForm::FormCollection, @contributors_form
  end

  test "project form provides getter method for project_tags sub-form" do
    assert_instance_of ActiveForm::FormCollection, @project_tags_form
  end

  test "project form provides getter method for owner sub-form" do
    assert_instance_of ActiveForm::Form, @owner_form
  end

  test "tasks sub-form contains association name and parent" do
    assert_equal :tasks, @tasks_form.association_name
    assert_equal 1, @tasks_form.records
    assert_equal @project, @tasks_form.parent
  end

  test "contributors sub-form contains association name and parent" do
    assert_equal :contributors, @contributors_form.association_name
    assert_equal 2, @contributors_form.records
    assert_equal @project, @contributors_form.parent
  end

  test "project-tags sub-form contains association name and parent" do
    assert_equal :project_tags, @project_tags_form.association_name
    assert_equal 1, @project_tags_form.records
    assert_equal @project, @project_tags_form.parent
  end

  test "owner sub-form contains association name and parent" do
    assert_equal :owner, @owner_form.association_name
    assert_equal @project, @owner_form.parent
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    assert @tasks_form.represents?("tasks")
    assert_not @tasks_form.represents?("task")

    assert @contributors_form.represents?("contributors")
    assert_not @contributors_form.represents?("contributor")

    assert @project_tags_form.represents?("project_tags")
    assert_not @project_tags_form.represents?("project_tag")

    assert @owner_form.represents?("owner")
    assert_not @owner_form.represents?("person")
  end

  test "project form provides getter method for task objects" do
    assert_respond_to @form, :tasks

    tasks = @form.tasks

    tasks.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
    end
  end

  test "project form provides getter method for contributor objects" do
    assert_respond_to @form, :contributors

    contributors = @form.contributors

    contributors.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Person, form.model
    end
  end

  test "project form provides getter method for project_tag objects" do
    assert_respond_to @form, :project_tags

    project_tags = @form.project_tags

    project_tags.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of ProjectTag, form.model
    end
  end

  test "project form provides getter method for owner object" do
    assert_respond_to @form, :owner

    owner = @form.owner

    assert_instance_of ActiveForm::Form, owner
    assert_instance_of Person, owner.model
  end

  test "project form initializes the number of records specified for tasks" do
    assert_respond_to @tasks_form, :models
    assert_equal 1, @tasks_form.models.size

    @tasks_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
      assert form.model.new_record?

      assert_respond_to form, :name
      assert_respond_to form, :name=
      assert_respond_to form, :description
      assert_respond_to form, :description=
      assert_respond_to form, :done
      assert_respond_to form, :done=
    end

    assert_equal 1, @form.model.tasks.size
  end

  test "project form initializes the number of records specified for contributors" do
    assert_respond_to @contributors_form, :models
    assert_equal 2, @contributors_form.models.size

    @contributors_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Person, form.model
      assert form.model.new_record?

      assert_respond_to form, :name
      assert_respond_to form, :name=
      assert_respond_to form, :role
      assert_respond_to form, :role=
      assert_respond_to form, :description
      assert_respond_to form, :description=
    end

    assert_equal 2, @form.model.contributors.size
  end

  test "project form initializes the number of records specified for project_tags" do
    assert_respond_to @project_tags_form, :models
    assert_equal 1, @project_tags_form.models.size

    @project_tags_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of ProjectTag, form.model
      assert form.model.new_record?

      assert_respond_to form, :tag_id
      assert_respond_to form, :tag_id=
    end

    assert_equal 1, @form.model.project_tags.size
  end

  test "project_tags sub-form declares the tag sub-form" do
    assert_equal 1, @project_tags_form.forms.size
    tag_form = @project_tags_form.models[0].tag

    assert_instance_of ActiveForm::Form, tag_form
    assert_equal :tag, tag_form.association_name
    assert_instance_of ProjectTag, tag_form.parent
    assert_instance_of Tag, tag_form.model

    assert_respond_to tag_form, :name
    assert_respond_to tag_form, :name=
  end

  test "reject owner if attributes are all blank" do
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Google Summer of Code 2014",

      owner_attributes: {
        name: "",
        role: "",
        description: ""
      }
    }

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_nil project_form.model.owner
  end

  test "reject contributor if attributes are all blank" do
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Google Summer of Code 2014",

      contributors_attributes: {
        "0" => {
          name: "Peter Markou",
          role: "Rails GSoC student",
          description: "Working on adding Form Models"
        },
        "1" => {
          name: "",
          role: "",
          description: ""
        }
      }
    }

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_equal 1, project_form.model.contributors.size
  end

  test "create new project with new tag" do
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Google Summer of Code 2014",

      project_tags_attributes: {
        "0" => {
          tag_attributes: {
            name: "Html Forms"
          }
        }
      }
    }

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Google Summer of Code 2014", project_form.description

    assert_equal 1, project_form.project_tags.size

    assert_equal "Html Forms", project_form.project_tags[0].tag.name
  end

  test "create new project with existing tag" do
    ## FAILS
    ProjectTag.delete_all
    Tag.delete_all

    tag = Tag.create(name: "Html Forms")
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Google Summer of Code 2014",

      project_tags_attributes: {
        "0" => { tag_id: tag.id }
      }
    }

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Google Summer of Code 2014", project_form.description

    assert_equal 1, project_form.project_tags.size

    assert_equal "Html Forms", project_form.project_tags[0].tag.name
  end

  test "update existing project with new tag" do
    project = Project.create(name: "Add Form Models", description: "Google Summer of Code 2014")
    project_form = ProjectForm.new(project)

    params = {
      project_tags_attributes: {
        "0" => {
          tag_attributes: {
            name: "Html Forms"
          }
        }
      }
    }

    project_form.submit(params)

    assert_difference('Project.count', 0) do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Google Summer of Code 2014", project_form.description

    assert_equal 1, project_form.project_tags.size

    assert_equal "Html Forms", project_form.project_tags[0].tag.name
  end

  test "update existing project with existing tag" do
    ## FAILS
    tag = Tag.create(name: "Html Forms")
    project = Project.create(name: "Form Models", description: "Google Summer of Code 2014")
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",

      project_tags_attributes: {
        "0" => { tag_id: tag.id }
      }
    }

    project_form.submit(params)

    assert_difference('Project.count', 0) do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Google Summer of Code 2014", project_form.description

    assert_equal 1, project_form.project_tags.size

    assert_equal "Html Forms", project_form.project_tags[0].tag.name
  end

  test "create new project with new owner" do
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      owner_attributes: {
        name: "Petros Markou",
        role: "Rails GSoC student",
        description: "Working on adding Form Models"
      }
    }

    before_owner = project_form.owner.model
    assert before_owner.new_record?
    assert_nil before_owner.name
    assert_nil before_owner.role
    assert_nil before_owner.description
    assert_nil project_form.model.owner

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Nesting models in a single form", project_form.description

    assert_not_nil project_form.model.owner
    assert_not_equal before_owner, project_form.model.owner
    assert_equal "Petros Markou", project_form.model.owner.name
    assert_equal "Rails GSoC student", project_form.model.owner.role
    assert_equal "Working on adding Form Models", project_form.model.owner.description

    assert_equal project_form.owner.model, project_form.model.owner

    assert_equal "Petros Markou", project_form.owner.name
    assert_equal "Rails GSoC student", project_form.owner.role
    assert_equal "Working on adding Form Models", project_form.owner.description
  end

  test "create new project with existing owner" do
    ## FAILS
    owner = Person.create(name: "Carlos Silva", role: "RoR Core Member", description: "Mentoring Peter throughout GSoC")
    project = Project.new
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      owner_id: owner.id
    }

    before_owner = project_form.owner.model
    assert before_owner.new_record?
    assert_nil before_owner.name
    assert_nil before_owner.role
    assert_nil before_owner.description
    assert_nil project_form.model.owner

    project_form.submit(params)

    assert_difference('Project.count') do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Nesting models in a single form", project_form.description

    assert_not_nil project_form.model.owner
    # the problem is that although we update the parent model, we don't
    # update the nested form's model.
    assert_not_equal before_owner, project_form.owner.model

    assert_equal "Carlos Silva", project_form.owner.name
    assert_equal "RoR Core Member", project_form.owner.role
    assert_equal "Mentoring Peter throughout GSoC", project_form.owner.description
  end

  test "update project with new owner" do
    project = Project.create(name: "Form Models", description: "GSoC 2014")
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      owner_attributes: {
        name: "Carlos Silva",
        role: "RoR Core Team",
        description: "Mentoring Peter throughout GSoC"
      }
    }

    project_form.submit(params)

    assert_difference('Project.count', 0) do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Nesting models in a single form", project_form.description

    assert_equal "Carlos Silva", project_form.owner.name
    assert_equal "RoR Core Team", project_form.owner.role
    assert_equal "Mentoring Peter throughout GSoC", project_form.owner.description
  end

  test "update project with existing owner" do
    ## FAILS
    owner = Person.create(name: "Carlos Silva", role: "RoR Core Member", description: "Mentoring Peter throughout GSoC")
    project = Project.create(name: "Form Models", description: "GSoC 2014")
    project_form = ProjectForm.new(project)

    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      owner_id: owner.id
    }

    project_form.submit(params)

    assert_difference('Project.count', 0) do
      project_form.save
    end

    assert_equal "Add Form Models", project_form.name
    assert_equal "Nesting models in a single form", project_form.description

    assert_equal "Carlos Silva", project_form.owner.name
    assert_equal "RoR Core Member", project_form.owner.role
    assert_equal "Mentoring Peter throughout GSoC", project_form.owner.description
  end

  test "project form initializes the owner record" do
    assert @owner_form.model.new_record?

    assert_respond_to @owner_form, :name
    assert_respond_to @owner_form, :name=
    assert_respond_to @owner_form, :role
    assert_respond_to @owner_form, :role=
    assert_respond_to @owner_form, :description
    assert_respond_to @owner_form, :description=
  end

  test "project form fetches task objects for existing Project" do
    project = projects(:yard)

    form = ProjectForm.new(project)

    assert_equal project.name, form.name
    assert_equal 2, form.tasks.size
    assert_equal project.tasks[0], form.tasks[0].model
    assert_equal project.tasks[1], form.tasks[1].model
  end

  test "project form fetches contributor objects for existing Project" do
    project = projects(:gsoc)

    form = ProjectForm.new(project)

    assert_equal project.name, "Add Form Models"
    assert_equal project.description, "Nesting models in a single form"
    assert_equal 2, form.contributors.size
    assert_equal project.contributors[0], form.contributors[0].model
    assert_equal project.contributors[1], form.contributors[1].model
  end

  test "project form fetches owner object for existing Project" do
    project = projects(:gsoc)

    form = ProjectForm.new(project)

    assert_equal project.name, "Add Form Models"
    assert_equal project.description, "Nesting models in a single form"
    assert_equal "Peter Markou", form.owner.name
    assert_equal "GSoC Student", form.owner.role
    assert_equal "Working on adding Form Models", form.owner.description
  end

  test "project form syncs its model and its tasks" do
    params = {
      name: "Add Form Models",

      tasks_attributes: {
        "0" => { name: "Form unit", description: "Form to represent a single model", done: false },
      }
    }

    @form.submit(params)

    assert_equal "Add Form Models", @form.name

    assert_equal "Form unit", @form.tasks[0].name
    assert_equal "Form to represent a single model", @form.tasks[0].description
    assert_equal false, @form.tasks[0].done

    assert_equal 1, @form.tasks.size
  end

  test "project form syncs its model and its contributors" do
    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      contributors_attributes: {
        "0" => { name: "Peter Markou", role: "GSoC Student", description: "Working on adding Form Models" },
        "1" => { name: "Carlos Silva", role: "RoR Core Member", description: "Assisting Peter throughout GSoC" }
      }
    }

    @form.submit(params)

    assert_equal "Add Form Models", @form.name
    assert_equal "Nesting models in a single form", @form.description

    assert_equal "Peter Markou", @form.contributors[0].name
    assert_equal "GSoC Student", @form.contributors[0].role
    assert_equal "Working on adding Form Models", @form.contributors[0].description

    assert_equal "Carlos Silva", @form.contributors[1].name
    assert_equal "RoR Core Member", @form.contributors[1].role
    assert_equal "Assisting Peter throughout GSoC", @form.contributors[1].description

    assert_equal 2, @form.contributors.size
  end

  test "project form saves its model and its tasks" do
    params = {
      name: "Add Form Models",
      description: "Nested models in a single form",

      tasks_attributes: {
        "0" => { name: "Form unit", description: "Form to represent a single model", done: "0" },
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Add Form Models", @form.name
    assert_equal "Nested models in a single form", @form.description

    assert_equal "Form unit", @form.tasks[0].name
    assert_equal "Form to represent a single model", @form.tasks[0].description
    assert_equal false, @form.tasks[0].done

    assert_equal 1, @form.tasks.size

    assert @form.persisted?
    @form.tasks.each do |task_form|
      assert task_form.persisted?
    end
  end

  test "project form saves its model and its contributors" do
    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      contributors_attributes: {
        "0" => { name: "Peter Markou", role: "GSoC Student", description: "Working on adding Form Models" },
        "1" => { name: "Carlos Silva", role: "RoR Core Member", description: "Assisting Peter throughout GSoC" }
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Add Form Models", @form.name
    assert_equal "Nesting models in a single form", @form.description

    assert_equal "Peter Markou", @form.contributors[0].name
    assert_equal "GSoC Student", @form.contributors[0].role
    assert_equal "Working on adding Form Models", @form.contributors[0].description

    assert_equal "Carlos Silva", @form.contributors[1].name
    assert_equal "RoR Core Member", @form.contributors[1].role
    assert_equal "Assisting Peter throughout GSoC", @form.contributors[1].description

    assert_equal 2, @form.contributors.size

    assert @form.persisted?
    @form.contributors.each do |contributor_form|
      assert contributor_form.persisted?
    end
  end

  test "project form updates its model and its tasks" do
    project = projects(:yard)
    form = ProjectForm.new(project)
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat", done: "1", id: tasks(:rake).id },
        "1" => { name: "Pray", done: "1", id: tasks(:paint).id },
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal true, form.tasks[0].done

    assert_equal "Pray", form.tasks[1].name
    assert_equal true, form.tasks[1].done

    assert_equal 2, form.tasks.size
  end

  test "project form updates its model and its contributors" do
    project = projects(:gsoc)
    form = ProjectForm.new(project)
    params = {
      name: "Add Form Models",
      description: "Nesting models in a single form",

      contributors_attributes: {
        "0" => { role: "CS Student", id: people(:peter).id },
        "1" => { role: "Plataformatec Engineer", id: people(:carlos).id }
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Add Form Models", form.name
    assert_equal "Nesting models in a single form", form.description

    assert_equal "Peter Markou", form.contributors[0].name
    assert_equal "CS Student", form.contributors[0].role
    assert_equal "Working on adding Form Models", form.contributors[0].description

    assert_equal "Carlos Silva", form.contributors[1].name
    assert_equal "Plataformatec Engineer", form.contributors[1].role
    assert_equal "Assisting Peter throughout GSoC", form.contributors[1].description

    assert_equal 2, form.contributors.size
  end

  test "project form responds to owner_id attribute" do
    attributes = [:owner_id, :owner_id=]

    attributes.each do |attribute|
      assert_respond_to @form, attribute
    end
  end

  test "project form responds to tasks writer method" do
    assert_respond_to @form, :tasks_attributes=
  end

  test "project form responds to contributors writer method" do
    assert_respond_to @form, :contributors_attributes=
  end

  test "project form responds to owner writer method" do
    assert_respond_to @form, :owner_attributes=
  end

end
