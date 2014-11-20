class Zone < ActiveRecord::Base
  belongs_to :domaine

  attr_accessible :_id, :nom, :lamb_x, :lamb_y, :temperature, :temperature_mer,
    :uv, :temps_sensible, :vent_vitesse, :vent_direction, :etat_mer
end
