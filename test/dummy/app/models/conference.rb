class Conference < ActiveRecord::Base
  has_one :speaker, dependent: :destroy
  validates :name, uniqueness: true

  def photo=(val)
    @photo = val.original_filename
  end

  def photo
    @photo
  end
end
