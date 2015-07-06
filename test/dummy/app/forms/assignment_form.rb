class AssignmentForm < ActionForm::Base
  self.main_model = :assignment
  
  attribute :name, required: true

  association :tasks, records: 3 do
    attribute :name, required: true
  end
end