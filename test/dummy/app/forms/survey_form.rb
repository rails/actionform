class SurveyForm < ActionForm::Base
  attribute :name, required: true

  association :questions do
    attribute :content, required: true

    association :answers, records: 2 do
      attribute :content, required: true
    end
  end
end
