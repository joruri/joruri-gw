class Gw::Admin::PropExtraPmMeetingroomsController < Gw::Admin::PropExtraPmGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @extra_genre = :pm

    @genre = 'meetingroom'
    @item_name = '会議室'
    @title_line = @item_name
    super
  end

  def index
    init_params
    Page.title = "実績詳細"
    return error_auth if !@is_pm_admin

    s_prop_name = nz(params[:s_prop_name], 0 ).to_s
    s_driver_gid = nz(params[:s_driver_gid], 0 ).to_s
    s_start_at = nz(params[:s_start_at], 2 ).to_s
    s_prop_state = nz(params[:s_prop_state], 100 ).to_s

    cond = "'#{@lastday_s}' < start_at" if params[:year].blank?
    cond = "end_at <= '#{@lastday_s}'" if params[:year] == "last"

    if !s_prop_name.blank? && s_prop_name != '0'
      cond += " and " if !cond.blank?
      cond += "car_id = '#{s_prop_name}'"
    end
    if !s_driver_gid.blank? && s_driver_gid != '0'
      cond += " and " if !cond.blank?
      cond += "driver_group_id = '#{params[:s_driver_gid]}'"
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

    join = "left join gw_schedule_props on gw_prop_extra_pm_meetingroom_actuals.schedule_prop_id = gw_schedule_props.id"

    @s_order = nz(params[:order], 'st_at').to_s.downcase # パラメタ受取り＆初期値設定
    @s_order = 'st_at' if %w(st_at group prop).index(@s_order).nil? # 許可値以外は初期値にもどす
    case @s_order
    when 'st_at'
      Page.title = '実績一覧'
      order = %Q(end_at desc)
      @items = @mdl_actual.where(cond).order(order).joins(join)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:driver_group, :driver_user, :meetingroom, :prop => :prop_extra_pm_meetingroom_actual)
      @prop_params = Gw::ScheduleProp.prop_params_set(params)
      @prop_list = Gw::ScheduleProp.select_prop_list('all', @genre)
      @driver_group_list = select_drivergroup_id_list('all')
      start_at_list_s = params[:year].blank? ? "all" : nil
      @start_at_list = select_start_at_list(start_at_list_s)
    when 'group'
      Page.title = '所属別実績一覧'
      order = %Q(driver_group_id)
      @items = @mdl_actual.select(:driver_group_id, :driver_group_name).group(:driver_group_id).order(order)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:driver_group)
    when 'prop'
      Page.title = '設備別実績一覧'
      order = %Q(car_id)
      @items = @mdl_actual.select(:car_id).group(:car_id).order(order)
        .paginate(page: params[:page], per_page: params[:limit])
        .preload(:meetingroom)
    end
  end

  def show_group
    init_params
    return error_auth if !@is_pm_admin

    @gid = params[:id]
    @s_order = nz(params[:mode], 'group').to_s.downcase # パラメタ受取り＆初期値設定
    @s_order = 'group' if %w(group prop).index(@s_order).nil? # 許可値以外は初期値にもどす
    case @s_order
    when 'group'
      title_s = '月別明細一覧'
      cond_order = "driver_group_id=#{@gid}"
      gname = Gw::Model::Schedule.get_gname(:gid=>@gid)
    when 'prop'
      title_s = '月別明細一覧'
      cond_order = "car_id=#{@gid}"
      gname = Gw::PropMeetingroom.where(:id=>@gid).first
      return http_error(404) if gname.blank?
      gname = gname.name
    else
      return error_auth
    end
    Page.title = "#{title_s} - #{gname}"
    cond_order += " and '#{@lastday_s}' < start_at" if params[:year].blank?
    cond_order += " and end_at <= '#{@lastday_s}'" if params[:year] == "last"

    @items = @mdl_actual
      .select("coalesce(date_format(end_at, '%Y-%m'),'貸出中') as _end_at_ym")
      .select("format(sum(time_to_sec(timediff(end_at,start_at)))/3600,1) as _time_sum")
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
    return if @item.nil?
    case @item[:action]
    when 'exec'
      re = /^\d{4}[\-\/]\d{1,2}/
      if @item.nil? || @item[:st_at].nil? || @item[:ed_at].nil? || re !~ @item[:st_at] || re !~ @item[:ed_at]
        flash[:notice] = '年月の指定が異常です'
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
          # 再集計/請求は現時点では行わない仕様
          items.each {|item|
            # PropExtraPmRentcarActual 対象レコードに集計/請求済フラグ設定
            if options[:mode] == :summarize
              item.update_columns(summaries_state: '1') # 集計済
            else
              item.update_columns(bill_state: '1') # 請求済
            end
            # summary Hash に集計
            end_ym = Gw.date_format('%Y/%m/1', item.end_at).to_date
            summary[end_ym] = {} if summary[end_ym].nil?
            summary[end_ym][item.driver_group_id] = {} if summary[end_ym][item.driver_group_id].nil?
            run_meter_wrk = nz(item.end_meter,0) - nz(item.start_meter,0)
            unit_price = nz(Gw::PropExtraPmRentcarUnitPrice.get_unit_price(item.end_at),40)
            summary[end_ym][item.driver_group_id][:sum_meter] = nz(summary[end_ym][item.driver_group_id][:sum_meter], 0) + run_meter_wrk
            summary[end_ym][item.driver_group_id][:sum_price] = nz(summary[end_ym][item.driver_group_id][:sum_price], 0) + run_meter_wrk * unit_price
          }
          summary.each{|ym, summary_detail|
            summary_detail.each{|gid, hx|
              if options[:mode] == :summarize
                # PropExtraPmRentcarSummary 集計レコードに集計結果レコード挿入
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
                # PropExtraPmRentcarSummary 集計レコードに請求済フラグを立てる
                summary_tbl = Gw::PropExtraPmRentcarSummary.where("summaries_at='#{ym}' and group_id=#{gid}").first
                summary_tbl.bill_state = '1'
                driver_g = Gw::Model::Schedule.get_group(:gid=>gid)
                driver_grp_s = "#{driver_g.code}#{driver_g.name}"
                summary_a.push [Gw.date_format('%Y/%m', ym), driver_grp_s, hx[:sum_price], hx[:sum_meter]]
              end
              summary_tbl.save!
            }
          }
          # PropExtraPmRentcarSummarizeHistory 集計/請求履歴レコード作成
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
        end # transaction ここまで
        if options[:mode] == :summarize
          location = Gw.chop_with("#{Site.current_node.public_uri}",'/')
          redirect_to location
        else
          # csv 出力
          nkf_s = @item[:nkf]
          nkf_s = nkf_s.blank? ? '' : "_#{nkf_s}"
          filename = "record_gw#{nkf_s}.csv"
          nkf_a = [['sjis','-s'],['utf8','-w']].assoc(nkf_s)
          nkf_options = nkf_a.blank? ? '-s' : nkf_a[1]
          file = Gw::Script::Tool.ary_to_csv(summary_a)
          #send_download "#{filename}", NKF::nkf(nkf_options,file)
          send_data( NKF::nkf(nkf_options,file),:filename => filename,:status => 200)
        end
      end
    else
    end
  end
end
