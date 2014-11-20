class ImportLogsController < ApplicationController

  # GET /import_logs
  # GET /import_logs.json
  def index
    self.refresh if params[:refresh]
    respond_to do |format|
      format.html
      format.json { render json: ImportLogsDatatable.new(view_context) }
    end
  end
end
