class CreateCartes < ActiveRecord::Migration
  def change
    create_table :cartes do |t|
      t.references :domaine
      t.string     :echeance
      t.timestamps
    end
  end
end
