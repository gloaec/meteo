class Domaine < ActiveRecord::Base
  belongs_to :prevision
  has_many :cartes, dependent: :destroy
  has_many :zones, dependent: :destroy

  attr_accessible :zone, :nom, :cartes_attributes, :zones_attributes
  accepts_nested_attributes_for :cartes, :zones
end
