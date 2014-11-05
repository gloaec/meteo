# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
NrjEit::Application.initialize!

# Devise Layouts
NrjEit::Application.config.to_prepare do
    Devise::SessionsController.layout "devise"
    Devise::RegistrationsController.layout proc{ |controller| user_signed_in? ? "application"   : "devise" }
    Devise::ConfirmationsController.layout "devise"
    Devise::UnlocksController.layout "devise"            
    Devise::PasswordsController.layout "devise"        
end

# Configure Mails
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options = {:host => 'nrjtv-eit.nrjtv.fr'}
ActionMailer::Base.smtp_settings = {
   #:address => "172.21.159.159",
   :address => "172.23.1.123",
   :port => 25
   #:authentication => :login
   #:domain => "nrj.fr",
   #:user_name => "tektv@nrj.fr",
   #:password => "tektv@nrj.fr",
   #:enable_starttls_auto => true
}
ActionMailer::Base.config.content_type = "text/html"
#ActionMailer::Base.perform_deliveries = true #try to force sending in development 
#ActionMailer::Base.raise_delivery_errors = true
