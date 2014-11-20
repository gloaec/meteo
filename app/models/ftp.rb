require 'net/ftp'

class Ftp < ActiveRecord::Base
  has_many :paths
  accepts_nested_attributes_for :paths, :reject_if => lambda { |a| a[:path].blank? }, :allow_destroy => true
  attr_accessible :host, :password, :user, :port, :passive, :paths_attributes
 
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
    Digest::SHA1.hexdigest(NrjMeteo::Application.config.secret_key_base)
  end
end
