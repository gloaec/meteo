class Prevision < ActiveRecord::Base
  belongs_to :rapport
  has_many :domaines, dependent: :destroy

  attr_accessible :echeance, :date, :domaines_attributes
  accepts_nested_attributes_for :domaines

  scope :with_zone, lambda { |zone| 
    joins(:domaines).where('domaines.zone = ?', zone)
  }
end
