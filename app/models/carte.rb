class Carte < ActiveRecord::Base
  belongs_to :domaine
  has_many :villes
end
