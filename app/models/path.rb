class Path < ActiveRecord::Base
  belongs_to :ftp
  has_many :rapports
end
