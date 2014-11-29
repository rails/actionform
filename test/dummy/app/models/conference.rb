class Conference < ActiveRecord::Base
  has_one :speaker, dependent: :destroy
  validates :name, uniqueness: true
end
