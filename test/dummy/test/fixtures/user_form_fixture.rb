class UserFormFixture < ActionForm::Base
  self.main_model = :user

  attributes :name, :age, :gender, required: true

  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
end