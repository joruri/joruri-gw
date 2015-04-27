class Gw::Admin::PropExtraGroupRentcarsController < Gw::Admin::PropExtraPmRentcarsController
  def pre_dispatch
    @extra_genre = :group
  end

  def init_params
    @cls = 'pm'
    @genre = 'rentcar'
    @item_name = 'レンタカー'
    @title_line = @item_name
    @uid = Core.user.id
    @gid = Core.user_group.id
    @group_rentcars = true
    @day = Date.today
    @nextday = @day + 1
#    @lastyear = @day <  Date.new(2001, 5, 1) ? @day.year - 1 : @day.year
    @lastyear = @day <=  Date.new(@day.year, 3, 31) ? @day.year - 1 : @day.year
    @lastday_s = @lastyear.to_s + "-3-31 23:59"
    @sp_mode = :prop
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    @mdl_actual = "Gw::PropExtraPm#{@genre.camelize}Actual".constantize
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
#    super
  end

  def index
    init_params
#    @genre = params[:s_genre]

    Page.title = "所属別実績一覧"
    unit_price = Gw::PropExtraPmRentcarUnitPrice.get_unit_price || 40

    toll_fee_seikyuuzumi = "sum(case when coalesce(bill_state, 2) = 1 then toll_fee else 0 end)"
    toll_fee_miseikyuu = "sum(case when coalesce(bill_state, 2) != 1 then toll_fee else 0 end)"

    end_meter = "coalesce(end_meter, 0)"
    start_meter = "coalesce(start_meter, 0)"
    _sum_price = "sum(#{end_meter} - #{start_meter}) * #{unit_price}"

    # 表示できるグループを取得する
    groups = Array.new
    range_parent_gids = Array.new
    range_gids = Array.new
    groups << @gid
    range_parent_gids = Gw::PropExtraGroupRentcarMaster.range_parent_gids(@uid)
    range_gids   = Gw::PropExtraGroupRentcarMaster.range_gids(@uid)
    present_gids = Gw::PropExtraPmRenewalGroup.get_present_gids(@gid)
    # 親グループ
    range_parent_gids.each do |range_parent_gid|
      parent = System::Group.find_by_id(range_parent_gid)
      childrens = parent.children
      childrens.each do |children|
        groups << children.id
      end
    end
    # グループ
    range_gids.each do |range_gid|
      groups << range_gid[1]
    end
    # 所属変更による旧所属
    present_gids.each do |present_gid|
      groups << present_gid
    end

    @items = @mdl_actual
      .select("driver_group_id, sum(#{end_meter} - #{start_meter}) as _sum_meter")
      .select("#{_sum_price} as _sum_price")
      .select("#{toll_fee_seikyuuzumi} + sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) = 1)) * #{unit_price} as _seikyuuzumi")
      .select("#{toll_fee_miseikyuu} + sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) != 1)) * #{unit_price} as _miseikyuu")
      .select("sum(toll_fee) as _toll_sum")
      .select("coalesce(#{_sum_price}, 0) + coalesce(sum(toll_fee), 0) as _total_sum")
      .joins("left join system_group_histories on system_group_histories.id = gw_prop_extra_pm_rentcar_actuals.driver_group_id")
      .where(driver_group_id: groups)
      .order("level_no, code, sort_no, driver_group_id")
      .group("driver_group_id")
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
