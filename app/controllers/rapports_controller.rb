class RapportsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  #skip_authorize_resource :only => :events
  #before_action :set_rapport, only: [:show, :edit, :update, :destroy, :events]


  # GET /rapports/refresh
  # GET /rapports/refresh.json
  def refresh
    render json: {foo: "bar"}
    render html: "coucou"
  end

  # GET /rapports
  # GET /rapports.json
  def index
    #@france = Fra
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
        format.html { redirect_to @rapport, notice: 'Channel was successfully created.' }
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
        format.html { redirect_to @rapport, notice: 'Channel was successfully updated.' }
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
      @rapport = Rapport.find(params[:id] || params[:rapport_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rapport_params
      params.require(:rapport).permit(:name, :queue_path, :error_path,
          :min_duration_error, :min_duration_warning, :min_gap_error, :min_gap_warning,
          :max_duration_error, :max_duration_warning, :max_gap_error, :max_gap_warning)
    end
end
