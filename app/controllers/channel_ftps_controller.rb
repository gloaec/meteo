class ChannelFtpsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_channel, only: [:create, :destroy]
  before_action :set_channel_ftp, only: [:destroy]

  # POST /channel_ftps
  # POST /channel_ftps.json
  def create
    @channel_ftp = @channel.channel_ftps.build(channel_ftp_params)
    respond_to do |format|
      if @channel_ftp.save
        format.html { redirect_to edit_channel_path(@channel), notice: 'Ftp was successfully added.' }
        format.json { render action: 'show', status: :created, location: @channel_ftp }
      else
        format.html { redirect_to edit_channel_path(@channel) }
        format.json { render json: @channel_ftp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channel_ftps/1
  # DELETE /channel_ftps/1.json
  def destroy
    @channel_ftp.destroy
    respond_to do |format|
      format.html { redirect_to edit_channel_path(@channel), notice: 'Ftp was successfully removed' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:channel_id])
    end

    def set_channel_ftp
      @channel_ftp = ChannelFtp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_ftp_params
      if params[:channel_ftp][:ftp_id] == "0" or params[:channel_ftp][:ftp_id].nil?
        params.require(:channel_ftp).permit(:success_path, ftp_attributes: [:id, :host, :user, :password, :port, :passive])
      else
        params.require(:channel_ftp).permit(:success_path, :ftp_id)
      end
    end
end
