class Poro
  include ActiveModel::Model

  attr_accessor :name, :city

  def save
    true
  end
end

class PoroFormFixture < ActionForm::Base
  self.main_model = :conference
  attributes :name, :city, required: true
end
