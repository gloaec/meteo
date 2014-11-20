class Carte < ActiveRecord::Base
  belongs_to :domaine
  has_many :villes, dependent: :destroy

  attr_accessible :echeance
end
