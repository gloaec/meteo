class Setting < ActiveRecord::Base
   
  validates_uniqueness_of :var
  validates_presence_of :value
   
  after_save :send_cron_later

  attr_accessible :var, :value

  #Setting.for(:display).set=(value)
  def self.for(var)
    find_or_create_by(var: var)
  end
   
  def set=(value)
    update_attributes(:value => value)
  end
    
  def send_cron_later
  #Using delayed job to run this later to not hold up an HTTP thread.
    delay.update_cron if var.eql?("FTP Update Interval")
  end
     
  def update_cron
    system 'bundle exec whenever --update-crontab store'
  end
end
