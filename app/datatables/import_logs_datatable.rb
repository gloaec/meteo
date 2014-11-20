class ImportLogsDatatable
  delegate :params, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: ImportLog.count,
      iTotalDisplayRecords: logs.total_entries,
      aaData: data
    }
  end

private

  def data
    logs.map do |log|
      [
        log.msg_class, 
        log.msg,
        log.created_at,
        log.id
      ]
    end
  end

  def logs
    @logs ||= fetch_logs
  end

  def fetch_logs
    logs = ImportLog.order("#{sort_column} #{sort_direction}")
    logs = logs.page(page).per_page(per_page)
    if params[:sSearch].present?
      logs = logs.where("msg like :search or msg_class like :search", search: "%#{params[:sSearch]}%")
    end
    logs
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[msg created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
