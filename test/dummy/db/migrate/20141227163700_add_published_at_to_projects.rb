class AddPublishedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :published_at, :datetime
  end
end
