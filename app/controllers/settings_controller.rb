class SettingsController < ApplicationController
  def index
    @settings = Setting.all
  end

  def save
    @settings = Setting.all
    @settings.each { |s| s.attributes = params[:setting][s.id.to_s] }
    if @settings.all?(&:valid?)
      @settings.each { |s| s.save }
    end
    #if Rails.env == 'production'
    #  `cd #{Rails.root} && RAILS_ENV=production \
    #   bundle exec rake whenever:update_crontab`
    #end
    flash[:notice] = "Les paramètres ont correctement été mis à jour"
    redirect_to settings_path
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def settings_params
      params.require(:setting)
      params[:settings]
    end
end
