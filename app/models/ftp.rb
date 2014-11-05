require 'net/ftp'

class Ftp < ActiveRecord::Base
  has_many :ftp_channels, class_name: 'ChannelFtp', dependent: :destroy
  has_many :channels, through: :ftp_channels, source: :channel
 
  def ping?
    ftp = nil
    begin 
      ftp = Net::FTP.new
      Timeout.timeout(10) do
        ftp.connect(self.host, self.port) 
        ftp.passive = self.passive || false
        ftp.login self.user, self.password
      end
    rescue
      false
    ensure
      ftp.close unless ftp.nil?
    end
  end

  def password=(new_password)
    self.password_digest = AESCrypt.encrypt_data(new_password, self.secret, nil, "AES-256-ECB")
  end
  

  def password
    AESCrypt.decrypt_data(self.password_digest, self.secret, nil, "AES-256-ECB")
  end

  protected

  def secret
    Digest::SHA1.hexdigest(NrjEit::Application.config.secret_key_base)
  end
end
