class Prevision < ActiveRecord::Base
  belongs_to :rapport
  has_many :domaines, dependent: :destroy

  attr_accessible :echeance, :date
end
