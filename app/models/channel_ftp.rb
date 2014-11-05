class ChannelFtp < ActiveRecord::Base
  self.table_name = "channels_ftps"
  belongs_to :channel
  belongs_to :ftp

  accepts_nested_attributes_for :ftp
end
