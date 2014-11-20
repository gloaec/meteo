require File.expand_path('../config/environment', __FILE__)
 
upload_interval = Setting.for('Intervalle de rafraîchissement FTP (min)').value || 15

every upload_interval.to_i.minutes do
  runner 'Rapport.fetch'
end
