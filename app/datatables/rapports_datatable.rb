class RapportsDatatable
  delegate :params, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Rapport.count,
      iTotalDisplayRecords: rapports.total_entries,
      aaData: data
    }
  end

private

  def data
    rapports.map do |rapport|
      display_name = "<i class='fa fa-code'></i> #{rapport.xml_file_name}".html_safe
      updated_at = "<span class='timeago' data-sort='#{rapport.updated_at}' data-datetime='#{rapport.updated_at}'></span>"
      infos = {
        paris: rapport.has_paris?,
        france: rapport.has_france?,
        monde: rapport.has_monde?,
        plages: rapport.has_plages?,
        neiges: rapport.has_neiges?,
        ephemerides: rapport.has_ephemerides?
      }
      [
        rapport.xml_file_name, #link_to(display_name, rapport),
        infos, #rapport.rapport_type, # 'icon-france'
        rapport.updated_at,
        rapport.id,
        !rapport.rapport_type.nil? && rapport == Rapport.where(rapport_type: rapport.rapport_type).order(:updated_at).last
      ]
    end
  end

  def rapports
    @rapports ||= fetch_rapports
  end

  def fetch_rapports
    rapports = Rapport.order("#{sort_column} #{sort_direction}")
    rapports = rapports.page(page).per_page(per_page)
    if params[:sSearch].present?
      rapports = rapports.where("xml_file_name like :search or rapport_type like :search", search: "%#{params[:sSearch]}%")
    end
    rapports
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[xml_file_name rapport_type updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
