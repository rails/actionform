class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true

  association :speaker do
    attribute :name, :occupation, required: true

    association :presentations, records: 2 do
      attribute :topic, :duration, required: true
    end
  end
end
