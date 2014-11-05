class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :channel, index: true
      t.boolean :notify_success, null: false, default: true      
      t.boolean :notify_error,   null: false, default: true      

      t.timestamps
    end
  end
end
