class Gw::Admin::PropExtraPmGenreCommonController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::Model::Schedule
  layout "admin/template/schedule"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
  end

  def init_params
    prop_classes = Gw::ScheduleProp.get_extra_classes(@genre)
    @cls = 'pm'
    @erb_base = "/#{@module}/public/#{Gw.join([@genre_prefix, 'extra'], '_').pluralize}" # /gw/public/prop_extras
    @extra_name_s = "#{@item_name}管理(#{prop_classes[@cls]})" # 会議室管理(管財)
    @uri_base = "/gw/prop_extra_pm_#{@genre}s"
    @uri_base_prop_extras = "/gw/prop_extras"
    @mdl_actual = "Gw::PropExtraPm#{@genre.camelize}Actual".constantize
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)

    @prop_state = [["すべて", 100], ["貸出中", 2], ["返却済", 3], ["集計済", 4], ["請求済", 5]]

    @day = Date.today
    @nextday = @day + 1
    @lastyear = @day <=  Date.new(@day.year, 3, 31) ? @day.year - 1 : @day.year
    @lastday_s = @lastyear.to_s + "-3-31 23:59"
    @sp_mode = :prop
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
  end

  def show
    init_params
    Page.title = "実績詳細"
    return error_auth if !@is_pm_admin && @extra_genre == :pm

    @item = @mdl_actual.find(params[:id])
  end

  def edit
    show
    @item.end_at ||= Time.now
    @item.title = @item.title.presence || @item.schedule.title
  end

  def show_group_month
    @s_order = nz(params[:mode], 'group').to_s.downcase
    @s_order = 'group' if %w(group prop).index(@s_order).nil?
    init_params
    return error_auth if !@is_pm_admin && @extra_genre == :pm

    @gid = params[:id]
    begin
      ym = params[:s_ym]
      raise if ym.blank?
      ym.scan(/^(\d{4})[\/-]?(\d{2})$/)
      raise if ym.blank?
      s_ym = "#$1/#$2"
      ym = Gw.ym_to_time(s_ym)
      @ym = "#$1-#$2"
      @ym = '貸出中' if @ym=='-'
      raise if ym.blank?
      date_cond = Gw.date_between_helper(:end_at, ym, ym.end_of_month)
    rescue
      date_cond = 'end_at is null'
    end
    case @s_order
    when 'group'
      cond = "driver_group_id=#{@gid} and #{date_cond}"
      title_s = '所属別実績明細'
      gname = Gw::Model::Schedule.get_gname(:gid=>@gid)
    when 'prop'
      cond = "car_id=#{@gid} and #{date_cond}"
      if @genre == "rentcar"
        title_s = '号車別実績明細'
        gname = Gw::PropRentcar.where(:id=>@gid).first
      else
        title_s = '会議室等別実績一覧'
        gname = Gw::PropMeetingroom.where(:id=>@gid).first
      end

      return http_error(404) if gname.blank?
      gname = gname.name
    else
      return error_auth
    end
    Page.title = "#{title_s} - #{gname} - #{@ym}"

    @items = @mdl_actual
      .select("gw_prop_extra_pm_#{@genre}_actuals.*, gw_prop_#{@genre}s.name as _prop_name")
      .joins("left join gw_schedule_props on gw_prop_extra_pm_#{@genre}_actuals.schedule_prop_id=gw_schedule_props.id")
      .joins("left join gw_prop_#{@genre}s on gw_schedule_props.prop_id=gw_prop_#{@genre}s.id")
      .where(cond)
      .order('end_at desc, _prop_name')
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:driver_group)

    case @genre
    when 'meetingroom' then @items.preload!(:meetingroom)
    when 'rentcar' then @items.preload!(:rentcar)
    end
  end

  def summarize
    Page.title  = "実績集計"
    _summarize :mode=>:summarize
  end

  def csvput
    Page.title  = "請求データ出力"
    _summarize :mode=>:csvput
  end

  def delete_prop
    init_params
    return error_auth unless @is_pm_admin

    item = @mdl_actual.find(params[:id])

    if item.schedule_prop.destroy # item.schedule.destroy
      flash_notice "予定、および実績の削除", true
    else
      flash_notice "予定、および実績の削除", false
    end

    redirect_to "/gw/prop_extra_pm_#{@genre}s"
  end

  def select_drivergroup_id_list(all=nil)
    driver_gname_list = [['すべて','0']] if all=='all'

    @mdl_actual.order(:driver_group_id).group(:driver_group_id).each do |item|
      group = System::GroupHistory.find_by_id(item.driver_group_id)
      driver_gname_list << [group.name , group.id] unless group.blank?
    end
    driver_gname_list
  end

  def select_start_at_list(all=nil)
    start_at_list  = []
    if all=='all'
      start_at_list = [["当日以降", "0"], ["当日", "1"], ["当日以前", "2"], ["すべて", "3"]]
      cond = "start_at > '#{@lastday_s}'"
    elsif all.blank?
      start_at_list = [["前年度以前すべて", "4"]]
      cond = "end_at <= '#{@lastday_s}'"
    end

    @mdl_actual.where(cond).order(start_at: :desc).group("date(start_at)").each do |item|
      start_at_list << [item.start_at.strftime("%Y-%m-%d") , item.start_at.strftime("%Y-%m-%d")]
    end
    return start_at_list
  end
end
