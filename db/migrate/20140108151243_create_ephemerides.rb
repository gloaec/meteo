class CreateEphemerides < ActiveRecord::Migration
  def change
    create_table :ephemerides do |t|
      t.references :rapport
      t.string     :echeance
      t.string     :lever
      t.string     :coucher
      t.integer    :variation
      t.timestamps
    end
  end
end
