class Gw::Admin::PropExtraPmRentcarsController < Gw::Admin::PropExtraPmGenreCommonController
  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
    @extra_genre = :pm
  end

  def init_params
    @genre = 'rentcar'
    @item_name = 'レンタカー'
    @title_line = @item_name
    super
  end

  def index
    init_params
    return error_auth if !@is_pm_admin

    @s_order = nz(params[:order], 'st_at').to_s.downcase # パラメタ受取り＆初期値設定
    @s_order = 'st_at' if %w(st_at group prop).index(@s_order).nil? # 許可値以外は初期値にもどす

    s_prop_name = nz(params[:s_prop_name], 0 ).to_s
    s_driver_gid = nz(params[:s_driver_gid], 0 ).to_s
    s_start_at = nz(params[:s_start_at], 2 ).to_s
    s_prop_state = nz(params[:s_prop_state], 100 ).to_s

    cond = ''
    if @s_order != 'group'
      cond = "'#{@lastday_s}' < start_at" if params[:year].blank?
      cond = "end_at <= '#{@lastday_s}'" if params[:year] == "last"
    end

    if !s_prop_name.blank? && s_prop_name != '0'
      cond += " and " if !cond.blank?
      cond += "car_id = '#{s_prop_name}'"
    end
    if !s_driver_gid.blank? && s_driver_gid != '0'
      cond += " and " if !cond.blank?
      cond += "driver_group_id = '#{s_driver_gid}'"
    end
    if !s_start_at.blank? && (s_start_at != '3' && s_start_at != '4')
      cond += " and " if !cond.blank?
      cond += "'#{@day.to_s} 00:00:00' < start_at" if s_start_at == '0'
      cond += "'#{@day.to_s} 00:00:00' < start_at and start_at < '#{@nextday.to_s} 00:00:00'" if s_start_at == '1'
      cond += "'#{@nextday.to_s} 00:00:00' > start_at" if s_start_at == '2'

      if s_start_at.split(//u).length != 1
        sday = s_start_at.to_date
        snextday = sday + 1
        cond += "'#{sday.to_s} 00:00:00' < start_at and start_at < '#{snextday.to_s} 00:00:00'"
      end
    end

    if !s_prop_state.blank? && s_prop_state != '100'
      cond += " and " if !cond.blank?
      cond += "gw_schedule_props.extra_data like '%\"rented\":1%' and gw_schedule_props.extra_data not like '%\"returned\":1%'" if s_prop_state == '2'
      cond += "gw_schedule_props.extra_data like '%\"returned\":1%' and summaries_state not like '1' and bill_state not like '1'" if s_prop_state == '3'
      cond += "summaries_state like '1' and bill_state not like '1' and gw_schedule_props.extra_data like '%\"returned\":1%'" if s_prop_state == '4'
      cond += "summaries_state like '1' and bill_state like '1'" if s_prop_state == '5'
    end

    join = "left join gw_schedule_props on gw_prop_extra_pm_rentcar_actuals.schedule_prop_id = gw_schedule_props.id"

    unit_price = nz(Gw::PropExtraPmRentcarUnitPrice.get_unit_price,40)
    end_meter = "coalesce(end_meter, 0)"
    start_meter = "coalesce(start_meter, 0)"

    case @s_order
    when 'st_at'
      Page.title = '実績一覧'
      order = %Q(end_at desc)
      @items = @mdl_actual.where(cond).order(order).joins(join)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:driver_group, :rentcar, :prop => :prop_extra_pm_rentcar_actual)
      @prop_params = Gw::ScheduleProp.prop_params_set(params)
      @prop_list = Gw::ScheduleProp.select_prop_list('all', @genre)
      @driver_group_list =  select_drivergroup_id_list('all')
      start_at_list_s = params[:year].blank? ? "all" : nil
      @start_at_list = select_start_at_list(start_at_list_s)

    when 'group'
      Page.title = '所属別実績一覧'
      order = %Q(updated_at)
      # http://www.geocities.jp/mickindex/database/db_case.html#LocalLink-sum
      # SQLのCASE文の使用方法
      toll_fee_seikyuuzumi = "sum(case when coalesce(bill_state, 2) = 1 then toll_fee else 0 end)"
      toll_fee_miseikyuu = "sum(case when coalesce(bill_state, 2) != 1 then toll_fee else 0 end)"

      _sum_price = "sum(#{end_meter} - #{start_meter}) * #{unit_price}"
      @items = @mdl_actual.select(:driver_group_id, :driver_group_name)
        .select("sum(#{end_meter} - #{start_meter}) as _sum_meter")
        .select("#{_sum_price} as _sum_price")
        .select("#{toll_fee_seikyuuzumi} + sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) = 1)) * #{unit_price} as _seikyuuzumi")
        .select("#{toll_fee_miseikyuu} + sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) != 1)) * #{unit_price} as _miseikyuu")
        .select("sum(toll_fee) as _toll_sum")
        .select("coalesce(#{_sum_price}, 0) + coalesce(sum(toll_fee), 0) as _total_sum")
        .where(cond).order(order).group(:driver_group_id)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:driver_group)
    when 'prop'
      Page.title = '設備別実績一覧'
      order = %Q(car_id)
      @items = @mdl_actual.select("car_id")
        .select("sum(#{end_meter} - #{start_meter}) as _sum_meter")
        .select("sum(#{end_meter} - #{start_meter}) * #{unit_price} as _sum_price")
        .select("sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) = 1)) * #{unit_price} as _seikyuuzumi")
        .select("sum((#{end_meter} - #{start_meter}) * (coalesce(bill_state,2) != 1)) * #{unit_price} as _miseikyuu")
        .group(:car_id).order(order)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:rentcar)
    end
  end

  def show_group
    init_params
    return error_auth if !@is_pm_admin && @extra_genre == :pm

    @gid = params[:id]
    _unit_price = Gw::PropExtraPmRentcarUnitPrice.get_unit_price
    @s_order = nz(params[:mode], 'group').to_s.downcase
    @s_order = 'group' if %w(group prop).index(@s_order).nil?
    cond_order = ""
    title_s = ""
    gname = ""
    case @s_order
    when 'group'
      title_s = '所属別明細一覧'
      cond_order += "summaries_state=1 and " if params[:total] == "1"
      cond_order += "driver_group_id=#{@gid}"
      group = System::GroupHistory.where(:id => @gid).first
      if group.blank?
        gname = ""
      else
        gname = group.name
      end
    when 'prop'
      title_s = '月別明細一覧'
      cond_order += "summaries_state=1 and " if params[:total] == "1"
      cond_order += "car_id=#{@gid}"
      gname = Gw::PropRentcar.where(:id => @gid).first
      return http_error(404) if gname.blank?
      gname = gname.name
    end
    Page.title = "#{title_s} - #{gname}"

    cond_order += " and '#{@lastday_s}' < start_at" if params[:year].blank?
    cond_order += " and end_at <= '#{@lastday_s}'" if params[:year] == "last"

    end_meter = "coalesce(end_meter, 0)"
    start_meter = "coalesce(start_meter, 0)"
    _price_sum = "sum(#{end_meter} - #{start_meter}) * #{_unit_price}"

    @items = @mdl_actual
      .select("coalesce(date_format(end_at, '%Y-%m'),'貸出中') as _end_at_ym")
      .select("count(id) as _use_num")
      .select("count(distinct date(end_at)) as _days_num")
      .select("sum(#{end_meter} - #{start_meter}) as _meter_sum")
      .select("#{_price_sum} as _price_sum")
      .select("coalesce(sum(toll_fee), 0) as _toll_sum")
      .select("coalesce(sum(refuel_amount), 0) as _refuel_sum")
      .select("max(bill_state) as _bill_state")
      .select("coalesce(#{_price_sum}, 0) + coalesce(sum(toll_fee), 0) as _total_sum, schedule_prop_id")
      .where(cond_order)
      .group("date_format(end_at, '%Y-%m')")
      .order('_end_at_ym desc')
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show_month
    # Gw::Admin::PropExtraGroupRentcarsControllerにも影響があるので注意。
    init_params
    return error_auth if !@is_pm_admin
    Page.title = "月別実績一覧"

    _unit_price = Gw::PropExtraPmRentcarUnitPrice.get_unit_price
    @s_order = nz(params[:mode], 'group').to_s.downcase # パラメタ受取り＆初期値設定
    @s_order = 'group' if %w(group prop).index(@s_order).nil? # 許可値以外は初期値にもどす
    cond_order = ""

    before_last_year = @lastyear - 1
    before_last_year_start_s = before_last_year.to_s + "-04-01 00:00"

    cond_order += "'#{@lastday_s}' < start_at" if params[:year].blank? || params[:year] != "last"
    cond_order += "'#{before_last_year_start_s}' <= start_at and end_at <= '#{@lastday_s}'" if params[:year] == "last"

    end_meter = "coalesce(end_meter, 0)"
    start_meter = "coalesce(start_meter, 0)"
    _price_sum = "sum(#{end_meter} - #{start_meter}) * #{_unit_price}"

    @items = @mdl_actual
      .select("coalesce(date_format(end_at, '%Y-%m'),'貸出中') as _end_at_ym")
      .select("count(id) as _use_num")
      .select("count(distinct date(end_at)) as _days_num")
      .select("sum(#{end_meter} - #{start_meter}) as _meter_sum")
      .select("#{_price_sum} as _price_sum")
      .select("coalesce(sum(toll_fee), 0) as _toll_sum")
      .select("coalesce(sum(refuel_amount), 0) as _refuel_sum")
      .select("max(bill_state) as _bill_state")
      .select("coalesce(#{_price_sum}, 0) + coalesce(sum(toll_fee), 0) as _total_sum")
      .where(cond_order)
      .group("date_format(end_at, '%Y-%m')")
      .order('_end_at_ym desc')
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def update
    init_params
    return error_auth unless @is_pm_admin

    @item = @mdl_actual.find(params[:id])
    @item.attributes = params[:item]
    @item.updated_user = Core.user.name
    @item.updated_group = "#{Core.user_group.code}#{Core.user_group.name}"

    _update @item, notice: "#{@item_name}の返却に成功しました"
  end

  def _summarize(options={})
    init_params
    return error_auth if !@is_pm_admin
    @item = params[:item]
    Page.title = @title_s
    return if @item.nil?
    case @item[:action]
    when 'exec'
      re = /^\d{4}[\-\/]\d{1,2}/
      @item = @item.merge({
        :st_at => @item[:st_at_year] + "/" + @item[:st_at_month],
        :ed_at => @item[:ed_at_year] + "/" + @item[:ed_at_month],
      })
      st_at = (@item[:st_at_year] + "-" + @item[:st_at_month] + "-01").to_date
      ed_at = (@item[:ed_at_year] + "-" + @item[:ed_at_month] + "-01").to_date
      today = Time.now.localtime.to_date
      if @item.nil? || @item[:st_at].nil? || @item[:ed_at].nil? || re !~ @item[:st_at] || re !~ @item[:ed_at] || ed_at < st_at
        flash[:notice] = '年月の指定が異常です'
      elsif ed_at > today
        flash[:notice] = '終了月が現在、もしくは未来になっています。過去の月を指定してください。'
      elsif (@item[:max_s].to_date < st_at || @item[:max_s].to_date < ed_at) && options[:mode] == :csvput
        flash[:notice] = '集計をしていない月を請求しようとしています。一度、集計を行ってください。'
      else
        # 集計処理メイン
        st_at = Gw.ym_to_time(@item[:st_at])
        ed_at = Gw.ym_to_time(@item[:ed_at], :day => -1)
        cond = Gw.date_between_helper(:end_at, st_at, ed_at)
        items = @mdl_actual.where(cond)
        summary = {}
        u = Core.user
        g = u.groups[0]
        summary_a = [] # CSV 用 array
        ActiveRecord::Base.transaction() do
          items.each {|item|
            if options[:mode] == :summarize
              item.update_columns(summaries_state: '1')
            else
              item.update_columns(bill_state: '1')
            end
            end_ym = Gw.date_format('%Y/%m/1', item.end_at).to_date
            summary[end_ym] = {} if summary[end_ym].nil?
            summary[end_ym][item.driver_group_id] = {} if summary[end_ym][item.driver_group_id].nil?
            run_meter_wrk = nz(item.end_meter,0) - nz(item.start_meter,0)
            unit_price = nz(Gw::PropExtraPmRentcarUnitPrice.get_unit_price(item.end_at),40)
            toll_fee = nz(item.toll_fee, 0)
            summary[end_ym][item.driver_group_id][:driver_user_id] = item.driver_user_id
            summary[end_ym][item.driver_group_id][:sum_meter] = nz(summary[end_ym][item.driver_group_id][:sum_meter], 0) + run_meter_wrk
            summary[end_ym][item.driver_group_id][:sum_price] = nz(summary[end_ym][item.driver_group_id][:sum_price], 0) + run_meter_wrk * unit_price + toll_fee
          }
          summary.each{|ym, summary_detail|
            summary_detail.each{|gid, hx|
              if options[:mode] == :summarize
                Gw::PropExtraPmRentcarSummary.destroy_all "summaries_at='#{Gw.date_str(ym)}' and group_id=#{gid}"
                summary_tbl = Gw::PropExtraPmRentcarSummary.new({
                  :summaries_at => ym,
                  :group_id => gid,
                  :run_meter => hx[:sum_meter],
                  :bill_amount => hx[:sum_price],
                  :bill_state => '2',
                  :updated_user => u.display_name,
                  :updated_group => g.name,
                  :created_user => u.display_name,
                  :created_group => g.name
                })
              else
                summary_tbl = Gw::PropExtraPmRentcarSummary.where("summaries_at='#{ym}' and group_id=#{gid}").first
                summary_tbl.bill_state = '1'
                driver_g = System::GroupHistory.where(:id => gid).first

                modified_at_cond = %Q(`modified_at` > '#{st_at.strftime('%Y-%m-%d 0:0:0')}' and `modified_at` < '#{ed_at.strftime('%Y-%m-%d 23:59:59')}')
                modified_at_items = Gw::PropExtraPmRenewalGroup.where(modified_at_cond)

                if modified_at_items.blank?
                  driver_grp_s = "#{driver_g.code}#{driver_g.name}"
                else
                  renewal_group = Gw::PropExtraPmRenewalGroup.where(:present_group_id => gid).first
                  if renewal_group.blank?
                    driver_grp_s = "#{driver_g.code}#{driver_g.name}"
                  else
                    incoming_group_id = renewal_group.incoming_group_id
                    incoming_group = System::GroupHistory.where(:id => incoming_group_id).first
                    driver_grp_s = "#{incoming_group.code}#{incoming_group.name}"
                  end
                end
                summary_a.push [Gw.date_format('%Y/%m', ym), driver_grp_s, hx[:sum_price], hx[:sum_meter]]
              end
              summary_tbl.save!
            }
          }
          hist = {
            :start_at => st_at,
            :end_at => ed_at,
            :updated_user => u.display_name,
            :updated_group => g.name,
            :created_user => u.display_name,
            :created_group => g.name
          }
          if options[:mode] == :summarize
            history_tbl = Gw::PropExtraPmRentcarSummarizeHistory.new(hist)
          else
            history_tbl = Gw::PropExtraPmRentcarCsvputHistory.new(hist)
          end
          history_tbl.save!
        end
        if options[:mode] == :summarize
          location = Gw.chop_with("#{url_for({:action=>:index})}/?s_prop_state=4&s_start_at=3",'/')
          redirect_to location
        else
          nkf_s = @item[:nkf]
          nkf_s = nkf_s.blank? ? '' : "_#{nkf_s}"
          filename = "record#{nkf_s}.csv"
          nkf_a = [['sjis','-s'],['utf8','-w']].assoc(nkf_s)
          nkf_options = nkf_a.blank? ? '-s' : nkf_a[1]
          header = ["年月", "請求先所属", "金額合計", "メーター合計"]
          file = Gw::Script::Tool.ary_to_csv(summary_a, {:header => header})
          send_data( NKF::nkf(nkf_options,file),:filename => filename,:status => 200)
        end
      end
    else
    end
  end
end
