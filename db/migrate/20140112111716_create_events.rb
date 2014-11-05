class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.integer :minimum_age
      t.datetime :start_at
      t.datetime :end_at
      t.integer :position
      t.references :program, index: true

      t.timestamps
    end
  end
end
