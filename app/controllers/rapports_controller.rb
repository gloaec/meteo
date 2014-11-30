class RapportsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  #skip_authorize_resource :only => :events
  #before_action :set_rapport, only: [:show, :edit, :update, :destroy, :events]

  def ephemerides
    @rapport = Rapport.where(rapport_type: :standard).order(:updated_at).last
  end

  def paris
    @rapport = Rapport.where(rapport_type: :standard).order(:updated_at).last
  end

  def france
    @rapport = Rapport.where(rapport_type: :standard).order(:updated_at).last
  end

  def monde
    @rapport = Rapport.where(rapport_type: :standard).order(:updated_at).last
  end

  def plages
    @rapport = Rapport.where(rapport_type: :plages).order(:updated_at).last
  end

  def neiges
    @rapport = Rapport.where(rapport_type: :neiges).order(:updated_at).last
  end

  # GET /rapports/refresh
  # GET /rapports/refresh.json
  def refresh
    flash[:warning] ||= []
    flash[:notice] ||= []

    created, updated, errors = Rapport.fetch

    errors.each do |error|
      flash[:warning] << error
    end

    msg = "<strong>Actualisation Terminée</strong><br />"
    msg+= "#{created.size} nouveau(x) fichier(s)<br />"
    if created.any?
      msg+= "<ul>"
      msg+= created.map {|r| "<li>#{view_context.link_to(r.xml_file_name, r)}</li>" }.join
      msg+= "</ul><br />"
    end
    msg+= "#{updated.size} fichier(s) mis à jour"
    if updated.any?
      msg+= "<ul>"
      msg+= updated.map {|r| "<li>#{view_context.link_to(r.xml_file_name, r)}</li>" }.join
      msg+= "</ul>"
    end
    flash[:notice] << msg.html_safe

  end

  # GET /rapports
  # GET /rapports.json
  def index
    self.refresh if params[:refresh]
    respond_to do |format|
      format.html
      format.json { render json: RapportsDatatable.new(view_context) }
    end
  end

  # GET /rapports/1
  # GET /rapports/1.json
  def show
  end

  # GET /rapports/beach/edit
  def edit
    @ftps = Ftp.select {|_| can?(:read, _) }
    @contacts = User.select {|_| can?(:read, _) }
  end

  # POST /rapports
  # POST /rapports.json
  def create
    @rapport = Rapport.new(rapport_params)

    respond_to do |format|
      if @rapport.save
        format.html { redirect_to @rapport, notice: 'Rapport was successfully created.' }
        format.json { render action: 'show', status: :created, location: @rapport }
      else
        format.html { render action: 'new' }
        format.json { render json: @rapport.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rapports/1
  # PATCH/PUT /rapports/1.json
  def update
    respond_to do |format|
      if @rapport.update(rapport_params)
        format.html { redirect_to @rapport, notice: 'Rapport was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rapport.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rapports/1
  # DELETE /rapports/1.json
  def destroy
    @rapport.destroy
    respond_to do |format|
      format.html { redirect_to rapports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rapport
      Rapport.find(params[:id] || params[:rapport_id])
      #@rapport = case id
      #  when 'paris' then Rapport.last
      #  else Rapport.find(id)
      #end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rapport_params
      params.require(:rapport).permit(:echeance,
        ephemerides_attributes: [
          :id, :echeance, :lever, :coucher, :variation
        ],
        previsions_attributes: [
          :id, :echeance,
          domaines_attributes: [
            :id, :zone, :nom,
            cartes_attributes: [
              :id, :echeance,
              villes_attributes: [
                :id, :nom, :temperature, :temperature_min, :temperature_max, 
                :uv, :temps_sensible, :vent_vitesse, :vent_direction
              ]
            ],
            zones_attributes: [
              :id, :nom, :temperature, :temperature_min, :temperature_max, 
              :uv, :temps_sensible, :vent_vitesse, :vent_direction,
              :temperature_mer, :etat_mer, :lamb_x, :lamb_y
            ]
          ]
        ]        
      )
    end
end
