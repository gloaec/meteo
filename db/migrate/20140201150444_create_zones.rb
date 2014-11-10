class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.references :domaine
      t.integer    :_id
      t.string     :nom
      t.integer    :lamb_x
      t.integer    :lamb_y
      t.integer    :temperature 
      t.integer    :temperature_mer
      t.integer    :uv
      t.string     :temps_sensible
      t.integer    :vent_vitesse
      t.string     :vent_direction
      t.string     :etat_mer
      t.timestamps
    end
  end
end
