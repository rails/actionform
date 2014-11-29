class Project < ActiveRecord::Base
  has_many :tasks
  has_many :contributors, :class_name => 'Person'
  belongs_to :owner, :class_name => 'Person'

  has_many :project_tags
  has_many :tags, through: :project_tags

  def photo=(val)
    @photo = val.original_filename
  end

  def photo
    @photo
  end
end
