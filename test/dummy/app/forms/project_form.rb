class ProjectForm < ActiveForm::Base
  attributes :name, :description, :owner_id, :published_at

  association :tasks do
    attributes :name, :description, :done, :finished_at

    association :sub_tasks do
      attributes :name, :description, :done
    end
  end

  association :contributors, records: 2 do
    attributes :name, :description, :role
  end

  association :project_tags do
    attribute :tag_id

    association :tag do
      attribute :name
    end
  end

  association :owner do
    attributes :name, :description, :role
  end
end
