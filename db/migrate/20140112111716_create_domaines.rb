class CreateDomaines < ActiveRecord::Migration
  def change
    create_table :domaines do |t|
      t.references :prevision
      t.string     :zone
      t.string     :nom
      t.timestamps
    end
  end
end
