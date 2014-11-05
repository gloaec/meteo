class ChannelUser < ActiveRecord::Base
  self.table_name = "channels_users"
  belongs_to :channel
  belongs_to :user
end
