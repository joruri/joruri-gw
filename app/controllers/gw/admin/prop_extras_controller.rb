class Gw::Admin::PropExtrasController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::Model::Schedule
  layout "admin/template/schedule"

  def pre_dispatch
    return redirect_to "/gw/prop_extras?s_genre=#{params[:s_genre]}&cls=#{params[:cls]}&order=#{params[:order]}" if params[:reset]
  end

  def init_params
    @module = 'gw'
    @genre_prefix = 'prop'
    a_genres = Gw::ScheduleProp.get_genres
    @genre = Gw.trim(nz(params[:s_genre])).downcase # meetingroom
    return http_error(404) if @genre.blank? || a_genres.assoc(@genre).nil?

    ignore_role = {}
    ignore_role = {:ignore_role => true} if params[:action] == "cancel" && @genre == "meetingroom"
    prop_classes = Gw::ScheduleProp.get_extra_classes @genre, ignore_role

    @cls = Gw.trim(nz(params[:cls])).downcase # pm
    return http_error(404) if @cls.blank? && @genre != "other"
    return error_auth if prop_classes[@cls].blank? && @genre != "other"

    @genre_name_s = Gw.join([@genre_prefix, @genre], '_').pluralize # prop_meetingrooms
    @genre_name_s = case @genre
    when 'meetingrooms'
      'prop_meetingrooms'
    when 'rentcars'
      'prop_rentcars'
    else
      'prop_others'
    end
    @erb_base = "/#{@module}/public/#{Gw.join([@genre_prefix, 'extra'], '_').pluralize}" # /gw/public/prop_extras
    @item_name = a_genres.assoc(@genre)[1] # 会議室
    @extra_name_s = "#{@item_name}管理(#{prop_classes[@cls]})" # 会議室管理(管財)
    @extra_model_s = "#{@module.capitalize}::#{@genre_prefix.capitalize}#{@genre.capitalize}" # Gw::PropMeetingroom
    @extra_model = eval(@extra_model_s)
    @uri_base_prop_extras = "/gw/prop_extras"
    @prop_params = Gw::ScheduleProp.prop_params_set(params)

    @gid = nz(params[:gid], Gw::Model::Schedule.get_user(@uid).groups[0].id) rescue Core.user_group.id

    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)

    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
  end

  def get_index_items
    # 当日貸出準備
    @results = nz(params[:results])
    if @results.blank?
      @results_flg = false
    else
      @results_flg = true
    end

    #@genre = params[:s_genre]
    @history = params[:history]
    @cal = params[:cal]

    case params[:s_genre]
    when 'meetingroom'
      Page.title = "会議室等予約一覧"
      Page.title = "当日貸出準備" if @results_flg
    when 'rentcar'
      Page.title = "レンタカー予約一覧"
    when 'other'
    end

    # リスト
    @owner_group_list = Gw::ScheduleProp.select_ownergroup_id_list('all', @extra_model_s)
    @prop_list = Gw::ScheduleProp.select_prop_list('all', @genre)
    if @results_flg
      @st_at_list = Gw::ScheduleProp.select_st_at_list('dynasty', @extra_model_s)
    else
      @st_at_list = Gw::ScheduleProp.select_st_at_list('all', @extra_model_s)
    end
    if @genre == "meetingroom"
      @prop_state_list = [["すべて", 100], ["未承認", 0], ["承認済", 1], ["貸出中", 2], ["返却済", 3], ["集計済", 4], ["請求済", 5], ["キャンセル", 900]]
    elsif @genre == "rentcar"
      @prop_state_list = [["すべて", 100], ["貸出前", 0], ["貸出中", 2], ["返却済", 3], ["集計済", 4], ["請求済", 5], ["キャンセル", 900]]
    end

    # 開始日が本日以前の履歴画面用
    today = Date.today
    nextday = today + 1

    # 初期パラメータ
    @s_owner_gid = nz(params[:s_owner_gid], 0 ).to_i
    @s_prop_state = nz(params[:s_prop_state], 100 ).to_i
    @s_st_at = nz(params[:s_st_at], 0 ).to_s
    @s_prop_name = nz(params[:s_prop_name], 0 ).to_i

    if @results_flg
      @s_st_at = nz(params[:s_st_at], today.strftime("%Y-%m-%d") )
    end

    item = Gw::ScheduleProp.new

    cond = "prop_type='#{@extra_model_s}' and extra_flag='#{@cls}' and gw_schedules.st_at  IS NOT NULL"

    # 日付関係。
    if !@s_st_at.blank? && @s_st_at != 3

      cond += " and '#{today.to_s} 00:00:00' <= gw_schedules.st_at" if @s_st_at == '0'
      cond += " and '#{today.to_s} 00:00:00' <= gw_schedules.st_at and gw_schedules.st_at < '#{nextday.to_s} 00:00:00'" if @s_st_at == '1'
      cond += " and '#{nextday.to_s} 00:00:00' >= gw_schedules.st_at" if @s_st_at == '2'

      if @s_st_at.split(//u).length != 1
        sday = @s_st_at.to_date
        snextday = sday + 1
        cond += " and '#{sday.to_s} 00:00:00' <= gw_schedules.st_at and gw_schedules.st_at < '#{snextday.to_s} 00:00:00'"
      end
    end

    if !@history.blank? && @s_st_at.blank?
      cond += " and '#{today.to_s} 00:00:00' <= gw_schedules.st_at and gw_schedules.st_at < '#{nextday.to_s} 00:00:00'" if !@history.blank? && @history == '1'
      cond += " and gw_schedules.st_at <= '#{today.to_s} 00:00:00'" if !@history.blank? && @history == '2'
    end

    cond += " and owner_gid = '#{@s_owner_gid}'" if !@s_owner_gid.blank? && @s_owner_gid != 0

    if @results_flg
      cond += " and (gw_schedule_props.extra_data IS NULL or gw_schedule_props.extra_data like '{\"confirmed\":1}')"
    else
      if !@s_prop_state.blank? && @s_prop_state != 100
        cond += " and gw_schedule_props.extra_data IS NULL" if @s_prop_state == 0
        cond += " and gw_schedule_props.extra_data like '{\"confirmed\":1}'" if @s_prop_state == 1
        cond += " and gw_schedule_props.extra_data like '%\"rented\":1%' and gw_schedule_props.extra_data not like '%\"returned\":1%'" if @s_prop_state == 2
        cond += " and gw_schedule_props.extra_data like '%\"returned\":1%' and summaries_state not like '1' and bill_state not like '1'" if @s_prop_state == 3
        cond += " and gw_schedule_props.extra_data like '%\"cancelled\":1%'" if @s_prop_state == 900
        cond += " and summaries_state like '1' and bill_state not like '1' and gw_schedule_props.extra_data like '%\"returned\":1%'" if @s_prop_state == 4
        cond += " and summaries_state like '1' and bill_state like '1'" if @s_prop_state == 5
      elsif @s_prop_state == 100 && @genre == "rentcar"
        cond += " and (gw_schedule_props.extra_data not like '%\"cancelled\":1%' or gw_schedule_props.extra_data is null)"
      end
    end

    extra_table_s = Gw.join([@module,@genre_prefix,@genre], '_').pluralize # gw_prop_meetingrooms
    extra_table_actuals_s = Gw.join([@module, @genre_prefix, "extra", 'pm', @genre, "actuals"], '_').pluralize # gw_prop_meetingrooms

    if !@s_prop_name.blank? && @s_prop_name != 0
      cond += " and #{extra_table_s}.id = '#{@s_prop_name}'"
    end

    # search params1(where で絞れるもの)
    cond += " and owner_gname like '%#{params[:s_subscriber]}%'" if !params[:s_subscriber].blank?

    # 一般施設の時、自所属の施設のみ表示させるようにしている。
    cond += " and gid like '#{@gid}'" if @genre == "other"

#    cond += " and bill_state = '1'"
    # cond += ...
    qsa = %w(s_genre cls s_subscriber)
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
    # 2系統のソート関連情報:
    #  :sort_keys -- ▲▼から来るソート情報
    #  :order -- 予約一覧 <=> 所属別一覧系
    order_a = []
    @sort_keys = CGI.unescape(nz(params[:sort_keys], ''))
    @sort_keys = "sort_no desc" if params[:sort_keys] == "_name desc"
    @sort_keys = "sort_no asc" if params[:sort_keys] == "_name asc"
    sk = @sort_keys
    if /^(_[_a-zA-Z]+) +(.+)$/ =~ sk
      after_sort_key = $1
      after_sort_order = $2
      sk = ''
    end
#    order_a.push sk

    order = nz(params[:order], 'st_at').to_s.downcase
    @s_order = order # パラメタ受取り＆初期値設定
    if @genre == "meetingroom"
      if @results_flg
        @s_order = "#{extra_table_s}.sort_no, gw_schedules.st_at"
      else
        @s_order = "gw_schedules.created_at DESC, gw_schedules.st_at"
      end
    else
      @s_order = "gw_schedules.st_at"
    end
    if order == 'group' && @genre == 'rentcar'
      @s_order = "gw_schedules.owner_gcode, gw_schedules.st_at"
    end

    join = "inner join gw_schedules on gw_schedule_props.schedule_id = gw_schedules.id"
    join += " left join gw_schedule_users on gw_schedule_users.schedule_id = gw_schedules.id"
    join += " left join #{extra_table_s} on gw_schedule_props.prop_id = #{extra_table_s}.id"
    join += " left join #{extra_table_actuals_s} on #{extra_table_actuals_s}.schedule_prop_id = gw_schedule_props.id" if @genre != "other"

    @all_items = Gw::ScheduleProp.joins(join).where(cond).order(@s_order).distinct
      .preload(:prop, :schedule => :schedule_events)
    @all_items.preload!(:prop_extra_pm_meetingroom_actual) if @genre == "meetingroom"
    @all_items.preload!(:prop_extra_pm_rentcar_actual) if @genre == "rentcar"

    @all_items.paginate(page: params[:page], per_page: params[:limit])
  end

  def index
    init_params
    @items = get_index_items
  end

  def csvput
    init_params
    items = get_index_items
    return error_auth unless @is_pm_admin

    # ファイル名生成
    filename = ""
    ### 号車、会議室名
    if @s_prop_name != 0
      s_prop_name = @prop_list.rassoc(@s_prop_name)
      filename += "_#{s_prop_name[0]}" if !s_prop_name.blank? && s_prop_name.instance_of?(Array) && !s_prop_name.empty?
    end
    ### 利用責任者所属
    if @s_owner_gid != 0
      s_owner_gid = @owner_group_list.rassoc(@s_owner_gid)
      filename += "_#{s_owner_gid[0]}" if !s_owner_gid.blank? && s_owner_gid.instance_of?(Array) && !s_owner_gid.empty?
    end
    ### 設備の状態
    if @s_prop_state != 100
      s_prop_state = @prop_state_list.rassoc(@s_prop_state)
      filename += "_#{s_prop_state[0]}" if !s_prop_state.blank? && s_prop_state.instance_of?(Array) && !s_prop_state.empty?
    end
    ### 開始日
    if @s_st_at != "3"
      s_st_at = @st_at_list.rassoc(@s_st_at)
      today = Date.today.strftime("%Y-%m-%d")
      filename += "_#{s_st_at[0].sub("当日", today)}" if !s_st_at.blank? && s_st_at.instance_of?(Array) && !s_st_at.empty?
    end

    case @genre
    when 'rentcar'
      filename = "レンタカー#{filename}.csv"
    else
      filename = "会議室#{filename}.csv"
    end

    csv_data = CSV.generate(force_quotes: true) do |csv|
      case @genre
      when 'rentcar'
        csv << ["設備の状態","号車","利用責任者所属","開始日","開始時刻","終了時刻","キャンセルユーザー","キャンセル日時"]
      else
        csv << ["会議室等名称","設備の状態","件名（用務名等）","庁内","庁外","利用責任者所属","利用責任者","開始日","開始時刻","終了時刻","登録日","キャンセルユーザー","キャンセル日時"]
      end

      @all_items.each do |item|
        data = []

        st_at_day = item.st_at ? I18n.l(item.st_at, format: :date_wday) : ""
        st_at_time = item.st_at ? I18n.l(item.st_at, format: :time) : ""
        ed_at_time = item.ed_at ? I18n.l(item.ed_at, format: :time) : ""
        cancelled_at_str = item.cancelled_at ? I18n.l(item.cancelled_at, format: :date_wday_time) : ""
        created_at_str = item.created_at ? I18n.l(item.created_at, format: :date_wday_time) : ""

        case @genre
        when 'rentcar'
          data << item.csv_prop_stat_s
          data << item.prop.try(:name)
          data << item.schedule.try(:owner_gname)
          data << st_at_day
          data << st_at_time
          data << ed_at_time
          data << item.cancelled_user_name
          data << cancelled_at_str
        else
          data << item.prop.try(:name)
          data << item.csv_prop_stat_s
          data << item.schedule.try(:title)
          data << item.schedule.try(:participant_nums_inner).to_i
          data << item.schedule.try(:participant_nums_outer).to_i
          data << item.schedule.try(:owner_gname)
          data << item.schedule.try(:owner_uname)
          data << st_at_day
          data << st_at_time
          data << ed_at_time
          data << created_at_str
          data << item.cancelled_user_name
          data << cancelled_at_str
        end

        csv << data
      end
    end

    send_data NKF::nkf('-s', csv_data), filename: filename
  end

  def list
    init_params

    success = 0
    failure = 0
    skip = 0
    confirmed_at = Time.now

    Gw::ScheduleProp.where(id: params[:ids]).each do |item|
      if item.confirmed?
        skip += 1
      else
        item.confirm!
        item.confirmed_at = confirmed_at
        if item.save
          success += 1
        else
          failure += 1
        end
      end
    end

    notices = []
    notices << "#{success}件を承認しました。" if success > 0
    notices << "#{failure}件の承認に失敗しました。" if failure > 0
    notices << "すでに承認済みの予定が#{skip}件ありました。それらは変更しておりません。" if skip > 0
    redirect_to "/gw/prop_extras#{@prop_params}", notice: notices.join('<br />')
  end

  def results_delete_list
    init_params

    success = 0
    failure = 0
    skip = 0
    Gw::ScheduleProp.where(id: params[:ids]).each do |item|
      if item.prop_extra_pm_actual.blank?
        if item.destroy # && item.schedule.destroy
          success += 1
        else
          failure += 1
        end
      else
        skip += 1
      end
    end

    notices = []
    notices << "#{success}件の予約を削除しました。" if success > 0
    notices << "#{failure}件の予約の削除に失敗しました。" if failure > 0
    notices << "貸出・返却済みの予約が#{skip}件ありました。そちらは削除しておりません。" if skip > 0
    redirect_to "/gw/prop_extras#{@prop_params}", notice: notices.join('<br />')
  end

  def confirm
    init_params
    item = Gw::ScheduleProp.find(params[:id])

    if item.confirmed?
      item.unconfirm!
      notice = "#{item.prop.try(:name)}の承認取消"
    else
      item.confirm!
      notice = "#{item.prop.try(:name)}の承認"
    end

    if item.save
      flash_notice notice, true
    else
      flash_notice notice, false
    end

    location = "/gw/prop_extras#{@prop_params}"
    location = "/gw/schedules/#{params[:sid]}/show_one" if params[:ref] == 'show_one'
    redirect_to location
  end

  def confirm_all
    init_params
    get_index_items

    @items = @all_items.select {|item| !item.confirmed? }

    success = 0
    failure = 0
    confirmed_at = Time.now
    @items.each do |item|
      item.confirm!
      item.confirmed_at = confirmed_at
      if item.save
        success += 1
      else
        failure += 1
      end
    end

    notices = []
    notices << "#{success}件の承認に成功しました" if success > 0
    notices << "#{failure}件の承認に失敗しました" if failure > 0
    notices << "未承認のデータがありませんでした。" if success == 0 && failure == 0
    redirect_to "/gw/prop_extras#{@prop_params}", notice: notices.join('<br />')
  end

  def cancel
    init_params
    item = Gw::ScheduleProp.find(params[:id])
    location = "/gw/prop_extras#{@prop_params}"
    location = "/gw/schedules/#{params[:sid]}/show_one" if params[:ref] == 'show_one'
    if item.cancelled?
      if !item.other_schedule_not_duplicate?
        flash_notice "競合する予定があるため、キャンセル取消を行うことができません。"
        return redirect_to location
      end
      item.uncancell!
      notice = "#{item.prop.try(:name)}のキャンセル取消"
    else
      item.cancell!
      notice = "#{item.prop.try(:name)}のキャンセル"
    end

    if item.cancellable? && item.save
      flash_notice notice, true
    else
      flash_notice notice, false
    end


    return redirect_to location
  end

  def rent
    init_params

    item = Gw::ScheduleProp.find(params[:id])
    return http_error(404) if item.blank?
    actual = nil

    if item.prop_stat == 2
      item.unrent!
      item.prop_extra_pm_actual.mark_for_destruction if item.prop_extra_pm_actual
      notice = "#{item.prop.try(:name)}の貸出取消"
    elsif item.prop_stat.to_i <= 1
      if item.meetingroom_related? && item.someone_renting_currently?
        flash[:notice] = '貸出に失敗しました。該当設備は貸出中です。'
        location = "/gw/prop_extras#{@prop_params}"
        location =  show_one_gw_schedule_path(params[:sid]) if params[:ref] == 'show_one'
        return redirect_to location
      end

      item.rent!

      actual =
        if item.meetingroom_related?
          item.build_prop_extra_pm_meetingroom_actual
        elsif item.rentcar_related?
          item.build_prop_extra_pm_rentcar_actual
        end

      if actual
        actual.attributes = {
          schedule_id: item.schedule_id,
          schedule_prop_id: item.id,
          car_id: item.prop_id,
          driver_user_id: item.schedule.try(:owner_uid),
          driver_group_id: item.schedule.try(:owner_gid)
        }
      end

      notice = "#{item.prop.try(:name)}の貸出"
    end

    if item.save
      flash_notice notice, true
    else
      flash_notice notice, false
    end

    location = "/gw/prop_extras#{@prop_params}"
    if actual
      location = case item.genre_name
      when 'meetingroom'
        gw_prop_extra_pm_meetingroom_path(actual)
      else
        gw_prop_extra_pm_rentcar_path(actual)
      end
    end

    location = show_one_gw_schedule_path(params[:sid]) if params[:ref] == 'show_one'
    return redirect_to location
  end

  def return
    item = Gw::ScheduleProp.find(params[:id])

    if item.rentcar_related?
      location = "/gw/prop_extra_pm_rentcars/#{item.prop_extra_pm_rentcar_actual.try(:id)}/edit"
    elsif item.meetingroom_related?
      location = "/gw/prop_extra_pm_meetingrooms/#{item.prop_extra_pm_meetingroom_actual.try(:id)}/edit"
    elsif item.other_related?
      if item.prop_stat == 2
        item.return!
        item.save
      end
      location = "/gw/prop_extras#{@prop_params}"
    end

    redirect_to location
  end

  def pm_create
    item = Gw::ScheduleProp.find(params[:id])
    return http_error(404) unless item.meetingroom_related?

    if item.prop_extra_pm_meetingroom_actual.present?
      return redirect_to "/gw/prop_extras#{@prop_params}", notice: "実績は既に作成されています。"
    end

    actual = item.build_prop_extra_pm_meetingroom_actual(
      schedule_id: item.schedule_id,
      schedule_prop_id: item.id,
      car_id: item.prop_id,
      driver_user_id: item.schedule.try(:owner_uid),
      driver_group_id: item.schedule.try(:owner_gid),
      start_at: item.st_at,
      end_at: item.ed_at
    )

    # 貸出＆返却
    if item.rent! == :rent_done && item.return! == :return_done && item.save
      flash_notice "実績の作成", true
    else
      flash_notice "実績の作成", false
    end

    redirect_to "/gw/prop_extra_pm_meetingrooms/#{actual.id}"
  end
end
