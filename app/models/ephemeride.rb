class Ephemeride < ActiveRecord::Base
  belongs_to :rapport
  attr_accessible :echeance, :lever, :coucher, :variation
end
