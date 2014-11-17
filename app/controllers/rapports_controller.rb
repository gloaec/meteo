class RapportsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  #skip_authorize_resource :only => :events
  #before_action :set_rapport, only: [:show, :edit, :update, :destroy, :events]


  def paris
    @rapport = Rapport.last
    render :show
  end

  def france
  end

  def plages
  end

  def neiges
  end

  def monde
  end

  # GET /rapports/refresh
  # GET /rapports/refresh.json
  def refresh
    flash[:warning] ||= []
    flash[:info] ||= []
    flash[:notice] ||= []
    updated  = []
    created  = []

    Ftp.all.each do |f|
      ftp = nil
      begin
        Timeout::timeout(10) do
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
            #rescue
              #results[f.id] = "#{f.user}@#{f.host}:#{path}"
            #  flash[:warning] << "Can't read #{f.user}@#{f.host}:#{path.path}"
            end
          end
          ftp.quit
          #p "   => OK"
        end
      #rescue #Timeout::Error
      #  flash[:warning] << "Can't connect to #{f.user}@#{f.host}"
      ensure
        begin
          ftp.close unless ftp.nil?
        rescue Net::FTPConnectionError
          flash[:warning] << "Can't connect to #{f.user}@#{f.host}"
        end
        f.save
      end
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
      Rapport.find(params[:id] || params[:rapport_id])
      #@rapport = case id
      #  when 'paris' then Rapport.last
      #  else Rapport.find(id)
      #end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rapport_params
      params.require(:rapport).permit(:name, :queue_path, :error_path,
          :min_duration_error, :min_duration_warning, :min_gap_error, :min_gap_warning,
          :max_duration_error, :max_duration_warning, :max_gap_error, :max_gap_warning)
    end
end
