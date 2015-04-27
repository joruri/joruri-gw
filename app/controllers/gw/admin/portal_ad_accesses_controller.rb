class Gw::Admin::PortalAdAccessesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @u_role = Gw::PortalAdd.is_admin?
    return error_auth unless @u_role

    Page.title = "広告アイコン管理"
  end

  def index
    @items = Gw::PortalAdd.order(sort_no: :asc, publish_start_at: :asc, publish_end_at: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    date_params(params)
    @item = Gw::PortalAdd.find(params[:id])

    acs = Gw::PortalAdDailyAccess.arel_table
    @accesses = @item.daily_accesses
      .select(acs[:accessed_at], acs[:click_count].sum.as('smy'))
      .where(acs[:accessed_at].gteq(@st_date)).where(acs[:accessed_at].lteq(@ed_date))
      .order(:accessed_at).group(:accessed_at)
    
    @accesses_by_day = @accesses.index_by{|a| a.accessed_at.day}
  end

  private

  def date_params(params)
    st_date = if params[:st_date].blank?
        Time.now
      else
        Time.parse("#{params[:st_date][:year]}-#{params[:st_date][:month]}-#{params[:st_date][:day]}") rescue Time.now
      end
    @st_date = st_date.beginning_of_month
    @ed_date = @st_date.end_of_month
  end
end
