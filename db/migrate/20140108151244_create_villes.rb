class CreateVilles < ActiveRecord::Migration
  def change
    create_table :villes do |t|
      t.references :carte
      t.string     :nom
      t.integer    :temperature
      t.integer    :temperature_min
      t.integer    :temperature_max
      t.integer    :uv
      t.string     :temps_sensible
      t.integer    :vent_vitesse
      t.string     :vent_direction
      t.timestamps
    end
  end
end
