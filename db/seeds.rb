# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#

# Users 
superadmin = User.create!({
  email:                 "superadmin@nrj.fr", 
  role:                  "superadmin", 
  password:              "superadmin12345", 
  password_confirmation: "superadmin12345" 
})

# Settings
Setting.for('Timeout FTP (sec)').set=(10)
Setting.for('Intervalle de rafraîchissement FTP (min)').set=(15)
