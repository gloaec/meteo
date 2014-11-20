class Domaine < ActiveRecord::Base
  belongs_to :prevision
  has_many :cartes, dependent: :destroy
  has_many :zones, dependent: :destroy

  attr_accessible :zone, :nom
end
