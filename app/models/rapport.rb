class Rapport < ActiveRecord::Base
  has_attached_file :xml
  has_many :previsions, dependent: :destroy
  has_many :ephemerides, dependent: :destroy

  after_save :update_directories

  def rapport_path
    if Rails.env == "production"
      File.expand_path(File.join(Rails.root, '..', '..', 'shared', 'rapports', self.id.to_s))
    else 
      File.join(Rails.root, 'rapports', self.id.to_s)
    end
  end
end
