class ProgramsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_authorize_resource :only => :events
  before_action :set_program, only: [:show, :edit, :update, :destroy, :transfer]
  before_action :set_programs, only: [:index]

  # GET /events.json
  def events
    from = Time.at(params[:from].to_i/1000)
    to = Time.at(params[:to].to_i/1000)
    @programs = Program
    .where(start_at: from.beginning_of_day..to.end_of_day)
    .select {|_| can?(:read, _)}
  end

  # POST /programs/1/transfer
  def transfer
    @program.transfer
    format.html { redirect_to @program, notice: 'Program was successfully transferred.' }
  end

  # GET /programs
  # GET /programs.json
  def index
  end

  # GET /programs/1
  # GET /programs/1.json
  def show
  end

  # GET /programs/new
  def new
    @program = Program.new
  end

  # GET /programs/1/edit
  def edit
    unless File.exists?(@program.xml.path)
      redirect_to @program, flash: { error: 'The file has already been transferred. You cannot edit it anymore.' }
    end
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(program_params)

    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: 'Program was successfully created.' }
        format.json { render action: 'show', status: :created, location: @program }
      else
        format.html { render action: 'new' }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programs/1
  # PATCH/PUT /programs/1.json
  def update
    respond_to do |format|
      results = []
      if @program.update(program_params)
        begin
          @program.reload
          @program.autocorrect if params[:autocorrect] == "1"
          results = @program.revalidate
        rescue Net::OpenTimeout
          format.html { redirect_to @program, flash: { warning: 'Program was validated but email was not sent..' }}
        rescue Net::FTPConnectionError
          format.html { redirect_to @program, flash: { warning: 'Program was validated but could\'t be transferred' }}
        #rescue Exception => e
        #  format.html { redirect_to @program, notice: "Error: #{e}" }
        else
          if results.empty?
            format.html { redirect_to @program, notice: 'Program was successfully updated.' }
          else
            ftps = results.map {|k, v| "<a href=\"#{edit_ftp_path(ChannelFtp.find(k.to_i).ftp)}\">#{v}</a>"}.join(', ')
            format.html { redirect_to @program, flash: { warning: "Program was validated but could\'t be transferred to : #{ftps}.<br /><strong>Make sure passive mode is enabled</strong>" }}
          end
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    @program.destroy
    respond_to do |format|
      format.html { redirect_to programs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program
      @program = Program.find(params[:id])
    end

    def set_programs
      @programs = Program
      .order(created_at: :desc)
      .select {|_| can?(:read, _) and _.dangers.any? }
      #.group_by{ |u| u.created_at.beginning_of_day }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def program_params
      _params = params.require(:program).permit(:notify_error, :notify_success, events_attributes: [:id, :name, :start_at, :end_at])
      end_at = set_program.start_at
      before_event = nil      

      _params[:events_attributes].map do |key, event_params|
         
        event = @program.events.find(event_params[:id])

        start_at = Time.parse("#{event_params[:start_at]} UTC", end_at)
        test = false
        if(end_at > start_at)
          gap = TimeDifference.between(start_at, end_at).in_hours
          if gap > 12
            end_at += 1.day
            start_at = Time.parse("#{event_params[:start_at]} UTC", end_at)
          end
        end
        event_params[:start_at] = start_at.iso8601

        end_at = Time.parse("#{event_params[:end_at]} UTC", start_at)
        if(start_at > end_at) 
          gap = TimeDifference.between(end_at, start_at).in_hours
          if gap > 12
            start_at += 1.day
            end_at = Time.parse("#{event_params[:end_at]} UTC", start_at)
          end
        end
        event_params[:end_at] = end_at.iso8601

        before_event = event

        [key, event_params]
      end
      _params
    end
end
