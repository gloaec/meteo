class Rapport < ActiveRecord::Base
  has_attached_file :xml
  has_many :previsions, dependent: :destroy
  has_many :ephemerides, dependent: :destroy
  belongs_to :path
  #before_create :import
  before_post_process :import

  attr_accessible :xml, :xml_file_name, :xml_content_type, :xml_file_size, :xml_updated_at,
      :date, :date_str, :rapport_type, :unites, :mtime

  def rapport_path
    if Rails.env == "production"
      File.expand_path(File.join(Rails.root, '..', '..', 'shared', 'rapports', self.id.to_s))
    else 
      File.join(Rails.root, 'rapports', self.id.to_s)
    end
  end

  def import
    path = self.xml.queued_for_write[:original].try(:path)
    path ||= self.xml.path

    begin
      f = File.open(path, 'r:iso-8859-1')
      doc = Nokogiri::XML(f, nil, 'iso-8859-1')
    rescue Exception => e
      ImportLog.create msg_class: 'danger', msg: "Can't read xml file \"#{path}\" : #{e.message}"
    end

    begin
      if doc.errors.any?
        doc.errors.each do |e|
          p "Error #{e}"                 
        end
      else

        # INFOS
        self.date = doc.css("date-fab").first.try(:content).try(:to_time)
        self.date_str = doc.css("date-fab-long").first.try(:content)
        self.unites = doc.css("unites").first.try(:content)
        self.rapport_type = nil
        self.rapport_type = :standard if doc.css("ephemeride").any? or doc.css("previsions").any?

        # EPHEMERIDES
        self.ephemerides.destroy_all
        ephemerides = doc.css("ephemeride")
        ephemerides.each do |ephemeride_node|
          ephemeride = self.ephemerides.build(
            echeance: ephemeride_node['echeance'],
            lever: ephemeride_node.css('lever').first.try(:content),
            coucher: ephemeride_node.css('coucher').first.try(:content),
            variation: ephemeride_node.css('variation').first.try(:content),
          )
        end

        # PREVISONS
        self.previsions.destroy_all
        previsions = doc.css("previsions")
        previsions.each do |prevision_node|
          prevision = self.previsions.build(
            echeance: prevision_node['echeance'], 
            date: prevision_node['date']
          )

          # DOMAINES
          domaines = doc.css("domaine")
          domaines.each do |domaine_node|
            domaine = prevision.domaines.build(
              nom: domaine_node['nom'],
              zone: domaine_node['zone']
            )

            # ZONES
            zones = domaine_node.css('zone')
            zones.each do |zone_node|
              zone = domaine.zones.build(
                _id: zone_node['id'],
                nom: zone_node['nom'],
                lamb_x: zone_node['lambX'],
                lamb_y: zone_node['lambY'],
                temperature: zone_node.css('TX').first.try(:content),
                temperature_mer: zone_node.css('Tmer').first.try(:content),
                uv: zone_node.css('UV').first.try(:content),
                temps_sensible: zone_node.css('tsensible').first.try(:content),
                vent_vitesse: zone_node.css('FF').first.try(:content),
                vent_direction: zone_node.css('DD').first.try(:content),
                etat_mer: zone_node.css('etatmer').first.try(:content)
              )
              self.rapport_type = :plages unless zone_node.css('Tmer').first.nil?
            end

            # CARTES
            cartes = domaine_node.css('cartes')
            cartes.each do |carte_node|
              carte = domaine.cartes.build(
                echeance: carte_node['echeance']
              )

              # VILLES
              villes = carte_node.css('ville')
              villes.each do |ville_node|
                ville = carte.villes.build(
                  nom: ville_node['nom'],
                  temperature: ville_node.css('t').first.try(:content),
                  temperature_min: ville_node.css('tmin').first.try(:content),
                  temperature_max: ville_node.css('tmax').first.try(:content),
                  uv: ville_node.css('uv').first.try(:content),
                  temps_sensible: ville_node.css('temps_sensible').first.try(:content),
                  vent_vitesse: ville_node.css('vent-vitesse').first.try(:content),
                  vent_direction: ville_node.css('vent-direction').first.try(:content)
                )
              end
            end
          end
        end
      end
    rescue Exception => e
      ImportLog.create msg_class: 'warning', msg: "Prolem while reading xml file \"#{path}\" : #{e.message}"
    ensure
      #self.save!
    end 
  end

  def self.fetch
    created  = []
    updated  = []
    errors   = []

    Ftp.all.each do |f|
      ftp = nil
      begin
        Timeout::timeout(Setting.for('Timeout FTP (sec)').value.to_i || 10) do
          ftp = Net::FTP.new
          ftp.passive = f.passive || false
          ftp.connect(f.host, f.port) 
          ftp.login f.user, f.password
          f.paths.each do |path|
            begin
              files = ftp.chdir(path.path)
              files = ftp.nlst '*.xml'
              files.each do |filename|
                mtime = ftp.mtime(filename)
                rapport = path.rapports.find_by xml_file_name: filename
                if rapport
                  if mtime == rapport.mtime
                  else
                    extname  = File.extname(filename)
                    basename = File.basename(filename, extname)
                    tempfile = Tempfile.new([basename, extname])
                    ftp.getbinaryfile(filename, tempfile.path)
                    rapport.xml = tempfile
                    rapport.mtime = mtime
                    rapport.xml_file_name = filename
                    rapport.save
                    updated << rapport
                  end
                else
                  extname  = File.extname(filename)
                  basename = File.basename(filename, extname)
                  tempfile = Tempfile.new([basename, extname])
                  ftp.getbinaryfile(filename, tempfile.path)
                  rapport = path.rapports.create xml: tempfile, mtime: mtime, xml_file_name: filename
                  created << rapport
                end
              end
            rescue Exception => e
              msg = "Can't read #{f.user}@#{f.host}:#{path.path} : #{e.message}"
              errors << msg
              ImportLog.create msg_class: 'danger', msg: msg
            end
          end
          ftp.quit
        end
      rescue Exception => e #Timeout::Error
        msg = "Can't connect to #{f.user}@#{f.host} : #{e.message}"
        errors << msg
        ImportLog.create msg_class: 'danger', msg: msg
      ensure
        begin
          ftp.close unless ftp.nil?
        rescue Net::FTPConnectionError
        end
        f.save
      end
    end
   
    if (created.any? or updated.any?) and errors.empty?
      c = 'success'
    elsif errors.any?
      c = 'warning'
    else
      c = 'info'
    end

    ImportLog.create msg_class: c, msg: "Actualisation terminée: #{created.size} nouveau(x) - #{updated.size} mis à jour - #{errors.size} erreurs"

    return created, updated, errors
  end

end
