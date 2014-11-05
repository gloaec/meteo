class ChannelSuccessContactsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_channel, only: [:create, :destroy]
  before_action :set_channel_success_contact, only: [:destroy]

  # POST /channel_success_contacts
  # POST /channel_success_contacts.json
  def create
    @channel_success_contact = @channel.channel_success_contacts.build(channel_success_contact_params)
    respond_to do |format|
      if @channel_success_contact.save
        format.html { redirect_to edit_channel_path(@channel), notice: 'Success contact was successfully added.' }
        format.json { render action: 'show', status: :created, location: @channel_success_contact }
      else
        format.html { redirect_to edit_channel_path(@channel) }
        format.json { render json: @channel_success_contact.errors, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotUnique
    respond_to do |format|
      format.html { redirect_to edit_channel_path(@channel), flash: {error: 'Already in contact list'} }
      format.json { render json: @channel_success_contact.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /channel_success_contacts/1
  # DELETE /channel_success_contacts/1.json
  def destroy
    @channel_success_contact.destroy
    respond_to do |format|
      format.html { redirect_to edit_channel_path(@channel), notice: 'Success contact was successfully removed' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:channel_id])
    end

    def set_channel_success_contact
      @channel_success_contact = ChannelSuccessContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_success_contact_params
      if params[:channel_success_contact][:user_id] == "0" or params[:channel_success_contact][:user_id].nil?
        contact = User.find_by_email(params[:channel_success_contact][:user_attributes][:email])
        unless contact.nil?
          _params = params.require(:channel_success_contact).permit()
          _params[:user_id] = contact.id
        else
          _params = params.require(:channel_success_contact).permit(user_attributes: [:id, :email, :role])
          password = SecureRandom.hex
          _params[:user_attributes][:password] = password
          _params[:user_attributes][:password_confirmation] = password
          _params[:user_attributes][:role] = 'contact'
        end
        _params
      else
        params.require(:channel_success_contact).permit(:user_id)
      end
    end
end
