class ChannelErrorContact < ActiveRecord::Base
  self.table_name = "channels_error_contacts"
  belongs_to :channel
  belongs_to :user

  accepts_nested_attributes_for :user
end
