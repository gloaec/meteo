class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #check_authorization

  before_filter :set_channels
  before_filter :default_url_options
  before_filter do # Cancan protected attributes workaround
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |e|
    if current_user.role? 'contact'
      sign_out current_user
      redirect_to new_user_session_path, flash: { error: e.message }
    else
      redirect_to root_path #new_user_session_path #, :alert => exception.message
    end
  end

  def set_channels
    @current_user = current_user || User.new
    @channels = Channel.all.select {|_| can?(:read, _)}
  end

  def current_ability
    current_user.ability
  end
end
