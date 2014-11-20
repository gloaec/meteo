class CreateImportLogs < ActiveRecord::Migration
  def change
    create_table :import_logs do |t|
      t.string :msg
      t.string :msg_class

      t.timestamps
    end
  end
end
