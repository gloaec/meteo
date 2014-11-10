class Domaine < ActiveRecord::Base
  belongs_to :prevision
  has_many :cartes
  has_many :zones
end
