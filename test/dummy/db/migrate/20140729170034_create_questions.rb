class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :content
      t.references :survey, index: true

      t.timestamps null: false
    end
  end
end
