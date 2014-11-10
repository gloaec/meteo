class CreateRapports < ActiveRecord::Migration
  def change
    create_table :rapports do |t|
      t.attachment :xml
      t.date       :date
      t.string     :date_str
      t.string     :type
      t.text       :unites
      t.timestamps
    end
  end
end
