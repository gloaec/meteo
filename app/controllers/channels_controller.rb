class ChannelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_authorize_resource :only => :events
  before_action :set_channel, only: [:show, :edit, :update, :destroy, :events]

  # GET /events.json
  def events
    from = Time.at(params[:from].to_i/1000)
    to = Time.at(params[:to].to_i/1000)
    @programs = @channel.programs.where(
      start_at: from.beginning_of_day..to.end_of_day
    )
  end

  # GET /channels
  # GET /channels.json
  def index
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
    @ftps = Ftp.select {|_| can?(:read, _) }
    @contacts = User.select {|_| can?(:read, _) }
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
        format.json { render action: 'show', status: :created, location: @channel }
      else
        format.html { render action: 'new' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id] || params[:channel_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      params.require(:channel).permit(:name, :queue_path, :error_path,
          :min_duration_error, :min_duration_warning, :min_gap_error, :min_gap_warning,
          :max_duration_error, :max_duration_warning, :max_gap_error, :max_gap_warning)
    end
end
