class Channel < ActiveRecord::Base
  #has_and_belongs_to_many :ftps
  #has_and_belongs_to_many :users
  has_many :channel_users, -> { where role: 'user' }, class_name: 'ChannelUser', dependent: :destroy
  has_many :channel_admins, -> { where role: 'admin' }, class_name: 'ChannelUser', dependent: :destroy
  has_many :users, through: :channel_users, source: :user
  has_many :admins, through: :channel_admins, source: :user

  has_many :channel_success_contacts, class_name: 'ChannelSuccessContact', dependent: :destroy
  #has_many :channel_success_contacts, -> { where success: true }, class_name: 'ChannelUser', dependent: :destroy
  has_many :success_contacts, through: :channel_success_contacts, source: :user
  has_many :channel_error_contacts, class_name: 'ChannelErrorContact', dependent: :destroy
  #has_many :channel_error_contacts, -> { where error: true }, class_name: 'ChannelUser', dependent: :destroy
  has_many :error_contacts, through: :channel_error_contacts, source: :user

  has_many :channel_ftps, class_name: 'ChannelFtp', dependent: :destroy
  has_many :ftps, through: :channel_ftps, source: :ftp
  has_many :programs, dependent: :destroy

  accepts_nested_attributes_for :ftps, :allow_destroy => true

  after_save :update_directories

  def channel_path
    if Rails.env == "production"
      File.expand_path(File.join(Rails.root, '..', '..', 'shared', 'channels', self.id.to_s))
    else 
      File.join(Rails.root, 'channels', self.id.to_s)
    end
  end

  def update_directories

    unless File.exists?(self.channel_path)
      FileUtils.mkdir_p self.channel_path
    end

    self.changes.each do |attr, value|
      old_value, new_value = value
      case attr
      when "queue_path" then
        path, directory = File.dirname(new_value), File.basename(new_value)
        if old_value != new_value
          if File.exists?(new_value)
            unless old_value.nil?
              if File.exists?(old_value)
                Dir.glob(File.join(old_value, '*')).each do |file|
                  FileUtils.mv file, File.join(self.channel_path, File.basename(file))
                end
              end
            end
            FileUtils.rm(new_value)
          else
            FileUtils.mkdir_p(path)
          end
          File.symlink(self.channel_path, new_value)
        end

      when "error_path" then
        FileUtils.mkdir_p(new_value) unless File.exists?(new_value)
        unless old_value.nil?
          if File.exists?(old_value)
            Dir.glob(File.join(old_value, '*')).each do |file|
              FileUtils.mv file, File.join(new_value, File.basename(file))
            end
          end
        end
      end
    end
  end
end
