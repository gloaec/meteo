class CreatePrevisions < ActiveRecord::Migration
  def change
    create_table :previsions do |t|
      t.references :rapport
      t.string     :echeance
      t.date       :date
      t.timestamps
    end
  end
end
