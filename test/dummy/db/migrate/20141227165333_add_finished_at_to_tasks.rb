class AddFinishedAtToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :finished_at, :datetime
  end
end
