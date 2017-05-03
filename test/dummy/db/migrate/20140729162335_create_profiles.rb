class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :twitter_name
      t.string :github_name
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
