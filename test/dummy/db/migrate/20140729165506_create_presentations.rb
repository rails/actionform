class CreatePresentations < ActiveRecord::Migration
  def change
    create_table :presentations do |t|
      t.string :topic
      t.string :duration
      t.references :speaker, index: true

      t.timestamps null: false
    end
  end
end
