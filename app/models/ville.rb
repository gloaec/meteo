class Ville < ActiveRecord::Base
  belongs_to :carte
  
  attr_accessible :nom, :temperature, :temperature_min, :temperature_max, :uv,
    :temps_sensible, :vent_vitesse, :vent_direction
end
