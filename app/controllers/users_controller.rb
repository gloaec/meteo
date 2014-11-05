class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  #skip_authorize_resource :only => :sessions
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  #rescue_from CanCan::AccessDenied do |exception|
  #  redirect_to root_url, :alert => exception.message
  #end

  # GET /users
  # GET /users.json
  def index
    @users = User.select{ |_| can? :read, _ }
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    Channel.select{ |_| can? :read, _ }.each do |channel|
      @user.user_channels.build channel: channel, role: "contact"
    end
  end

  # GET /users/1/edit
  def edit
    role = "admin" if @user.role? 'superadmin'
    Channel.select{ |_| can? :read, _ }.each do |channel|
      unless @user.user_channels.where(channel: channel).any?
        @user.user_channels.build channel: channel, role: role
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    build_contact_channels
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    build_contact_channels
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if params[:user][:password] == "" or params[:user][:password_confirmation] == ""
        if can? :manage, User
          params.require(:user).permit(:email, :role, user_channels_attributes: [:id, :channel_id, :role, :success, :error])
        else 
          params.require(:user).permit(:email, user_channels_attributes: [:id, :channel_id, :success, :error])
        end
      else
        if can? :manage, User
          params.require(:user).permit(:email, :role, :password, :password_confirmation, user_channels_attributes: [:id, :channel_id, :role, :success, :error])
        else
          params.require(:user).permit(:email, :password, :password_confirmation, user_channels_attributes: [:id, :channel_id, :success, :error])
        end 
      end
    end

    def build_contact_channels
      unless user_params[:user_channels_attributes].nil?
        user_params[:user_channels_attributes].each do |k, contact_channel|
          success_channel = @user.success_contact_channels.where(channel_id: contact_channel[:channel_id]).first
          error_channel = @user.error_contact_channels.where(channel_id: contact_channel[:channel_id]).first
          if contact_channel[:success]
            @user.success_contact_channels.build(channel_id: contact_channel[:channel_id]) unless success_channel
          else 
            success_channel.destroy unless success_channel.nil?
          end
          if contact_channel[:error]
            @user.error_contact_channels.build(channel_id: contact_channel[:channel_id]) unless error_channel
          else 
            error_channel.destroy unless error_channel.nil?
          end 
        end
      end
    end
end
