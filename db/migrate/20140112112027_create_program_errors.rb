class CreateProgramErrors < ActiveRecord::Migration
  def change
    create_table :program_errors do |t|
      t.string :code
      t.string :msg
      t.string :classname
      t.integer :line
      t.references :before_event, index: true
      t.references :after_event, index: true
      t.references :program, index: true

      t.timestamps
    end
  end
end
