class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.string :queue_path
      t.string :error_path
      t.integer :max_duration_error,    default: 0 
      t.integer :max_gap_error,         default: 0 
      t.integer :max_duration_warning,  default: 0 
      t.integer :max_gap_warning,       default: 0 
      t.integer :min_duration_error,    default: 0
      t.integer :min_gap_error,         default: 0
      t.integer :min_duration_warning,  default: 0
      t.integer :min_gap_warning,       default: 0
      t.timestamps
    end
  end
end
