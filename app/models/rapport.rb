class Rapport < ActiveRecord::Base
  has_attached_file :xml
  has_many :previsions, dependent: :destroy
  has_many :ephemerides, dependent: :destroy
  belongs_to :path

  before_save :import
  #before_post_process :import

  def rapport_path
    if Rails.env == "production"
      File.expand_path(File.join(Rails.root, '..', '..', 'shared', 'rapports', self.id.to_s))
    else 
      File.join(Rails.root, 'rapports', self.id.to_s)
    end
  end

  def import
    begin
      path = self.xml.queued_for_write[:original].try(:path)
      path ||= self.xml.path
      f = File.open(path, 'r:iso-8859-1')
      doc = Nokogiri::XML(f, nil, 'iso-8859-1')
    #rescue Exception => e
      #p "Exception #{e}"                 
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
            end

            # CARTES
            cartes = domaine_node.css('cartes')
            cartes.each do |carte_node|
              carte = domaine.cartes.build(
                echeance: carte_node['echeance']
              )
              p "========================================================="
              p carte_node['echeance']
              p "========================================================="
              
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
    #rescue Exception => e
    #  p "Exception #{e}"                 
    ensure
      #self.save!
    end 
  end

end
