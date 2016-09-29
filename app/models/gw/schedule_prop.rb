class Gw::ScheduleProp < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::Gw::Schedule::Prop

  attr_accessor :_skip_destroy_actual

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :prop, :polymorphic => true
  has_one :prop_extra_pm_rentcar_actual, :class_name => 'Gw::PropExtraPmRentcarActual'
  has_one :prop_extra_pm_meetingroom_actual, :class_name => 'Gw::PropExtraPmMeetingroomActual'

  belongs_to :confirmed_user, :foreign_key => :comfirmed_uid, :class_name => 'System::User'
  belongs_to :confirmed_group, :foreign_key => :comfirmed_gid, :class_name => 'System::Group'
  belongs_to :rented_user, :foreign_key => :rented_uid, :class_name => 'System::User'
  belongs_to :rented_group, :foreign_key => :rented_gid, :class_name => 'System::Group'
  belongs_to :returned_user, :foreign_key => :returned_uid, :class_name => 'System::User'
  belongs_to :returned_group, :foreign_key => :returned_gid, :class_name => 'System::Group'
  belongs_to :cancelled_user, :foreign_key => :cancelled_uid, :class_name => 'System::User'
  belongs_to :cancelled_group, :foreign_key => :cancelled_gid, :class_name => 'System::Group'

  accepts_nested_attributes_for :prop_extra_pm_rentcar_actual
  accepts_nested_attributes_for :prop_extra_pm_meetingroom_actual

  after_destroy :destroy_actual, unless: :_skip_destroy_actual

  scope :scheduled_between, ->(st_date, ed_date) {
    where(arel_table[:ed_at].gteq(st_date)).where(arel_table[:st_at].lt(ed_date + 1))
  }
  scope :preload_schedule_relations, ->{
    preload(:schedule => {
      :schedule_events => nil,
      :schedule_users => {:user => :user_groups},
      :schedule_props => {:prop => :prop_other_roles},
      :child => {:schedule_users => nil, :schedule_props => {:prop => :prop_other_roles}}})
  }

  def genre_name
    self.prop_type.to_s.sub('Gw::Prop', '').downcase
  end


  def pm_related?
    meetingroom_related? || rentcar_related?
  end

  def prop_extra_pm_actual_model
    case self.prop_type
    when 'Gw::PropMeetingroom' then Gw::PropExtraPmMeetingroomActual
    when 'Gw::PropRentcar' then Gw::PropExtraPmRentcarActual
    end
  end

  def prop_extra_pm_actual
    case self.prop_type
    when 'Gw::PropMeetingroom' then self.prop_extra_pm_meetingroom_actual
    when 'Gw::PropRentcar' then self.prop_extra_pm_rentcar_actual
    end
  end

  def date_between?(date)
    date == self.st_at.to_date || date == self.ed_at.to_date || (self.st_at.to_date < date && date < self.ed_at.to_date)
  end


  def self.is_pm_admin?
    # 管財管理人権限の有無
    return true if Gw.is_admin_admin?
    self.is_admin? nil, 'pm'
  end

  def self.select_ownergroup_id_list(all = nil, extra_model_s = "")
    items = self.joins(:schedule)
      .select("gw_schedules.owner_gid as gid, gw_schedules.owner_gcode as gcode, gw_schedules.owner_gname as gname")
      .where(prop_type: extra_model_s).where.not(gw_schedules: {owner_gid: nil})
      .group("gw_schedules.owner_gid")

    options = []
    options = [['すべて','0']] if all=='all'
    options += items.map{|item| ["#{item.gname}(#{item.gcode})", item.gid]}
  end

  def self.select_prop_list(all=nil, genre=nil)
    model = case genre
      when "meetingroom"
        Gw::PropMeetingroom
      when "rentcar"
        Gw::PropRentcar
      when "other"
        Gw::PropOther
      end

    items = model.order(:sort_no).to_a
    prop_list = [['すべて','0']] if all=='all'
    items.each do |item|
      prop_list << [item.name , item.id]
    end
    return prop_list
  end

  def self.select_st_at_list(all = nil, extra_model_s = "")
    items = self.joins(:schedule).select("DATE_FORMAT(gw_schedules.st_at, '%Y-%m-%d') as schedule_st_at")
      .where(prop_type: extra_model_s).where.not(gw_schedules: {st_at: nil})
      .order("gw_schedules.st_at DESC")
      .group("DATE(gw_schedules.st_at)").limit(200)

    options = []
    options = [["当日以降", "0"], ["当日", "1"], ["当日以前", "2"], ["すべて", "3"]] if all == 'all'
    options = [["当日以降", "0"]] if all == 'dynasty'
    options += items.map {|item| [item.schedule_st_at , item.schedule_st_at] }
  end

  def self.prop_params_set(_params)

    keys = 'cls:s_genre:s_prop_name:s_subscriber:page:sort_keys:history:s_owner_gid:s_prop_state:s_st_at:s_year:s_month:s_day:results'
    keys = keys.split(':')
    ret = ""
    keys.each_with_index do |col, idx|
      unless _params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{_params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.is_admin?(genre, extra_flag, options={})
    _ef = nz(extra_flag, 'other')
    return true if _ef == 'other'
    user = options[:user] || Core.user
    if genre.blank?
      return user.has_role?("gw_props/#{extra_flag}")
    else
      prop_classes = Gw::ScheduleProp.get_extra_classes genre, options
      return prop_classes.key?(extra_flag)
    end
  end

  def search_where(params)
    ret_a = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_genre'
        prop_type = "Gw::Prop#{v.capitalize}"
        ret_a.push "prop_type='#{prop_type}'"
      end
    end if params.size != 0
    return ret_a.collect{|x| "(#{x})"}.join(" and ")
  end

  def self.get_genres
    'meetingroom/会議室等:rentcar/レンタカー:other/一般施設'.split(':').map{|x| x.split('/')}
  end

  def self.get_genre_select(options={})
    key_prefix = options[:key_prefix].nil? ? '' : options[:key_prefix]
    types = Gw::PropType.select(:id, :name).where(state: 'public')
    types = types.where(restricted: 0) if options[:without_restricted]
    types = types.order(sort_no: :asc, id: :asc).map {|type| ["+-#{type.name}", "other:other:#{type.id}"] }

    if options[:reverse]
      [['一般施設', 'other:other:0']] + types +
      [['レンタカー(管財課)', "#{key_prefix}rentcar:pm"],
       ['会議室等(管財課)', "#{key_prefix}meetingroom:pm"]]
    else
      [['会議室等(管財課)', "#{key_prefix}meetingroom:pm"],
       ['レンタカー(管財課)', "#{key_prefix}rentcar:pm"],
       ['一般施設', 'other:other:0']] + types
    end
  end

  def self.prop_conv(conv, val)
    ret = case conv
    when :genre_to_mdl
      "Gw::Prop#{val.camelize}"
    when :mdl_to_genre
      val.sub(/^Gw::Prop/, '').underscore
    end
    return ret
  end

  def owner_s(options={})
    genre = prop.class.name.split('::').last.gsub(/^Prop/, '').downcase
    owner_class = prop.extra_flag
    case genre
    when 'other'
      prop.gname
    else
      prop_classes_raw[genre][owner_class]
    end
  end

  def prop_stat_s
    if prop_type == "Gw::PropRentcar"
      stats = [[0,'<span style="color:#FF0000;">未承認</span>'], [1, '<span style="color:#2E49B4;">承認済</span>'], [2, '<span style="color:#FF3F38;">貸出中</span>'], [3, '<span>返却済</span>'], [4, '<span style="color:#860000;">集計済</span>'], [5, '<span style="color:#FFC5FF;">請求済</span>'], [900, '<span style="color:#008100;">キャンセル</span>'], [nil, '(承認不要)']]
    elsif prop_type == "Gw::PropMeetingroom"
      stats = [[0,'<span style="color:#FF0000;">未承認</span>'], [1, '<span style="color:#2E49B4;">承認済</span>'], [2, '<span style="color:#FF3F38;">貸出中</span>'], [3, '<span style="color:#CFD0D2;">返却済</span>'], [4, '<span style="color:#860000;">集計済</span>'], [5, '<span style="color:#FFC5FF;">請求済</span>'], [900, '<span style="color:#008100;">キャンセル</span>'], [nil, '(承認不要)']]
    else
      stats = [[0,'<span style="color:#FF0000;">未承認</span>'], [1, '<span style="color:#2E49B4;">承認済</span>'], [2, '<span style="color:#FF3F38;">貸出中</span>'], [3, '<span style="color:#CFD0D2;">返却済</span>'], [4, '<span style="color:#860000;">集計済</span>'], [5, '<span style="color:#FFC5FF;">請求済</span>'], [900, '<span style="color:#008100;">キャンセル</span>'], [nil, '(承認不要)']]
    end

    stat = stats.assoc(prop_stat)
    return nil if stat.blank?
    return nil if stat[1].blank?
    return stat[1].html_safe
  end
  def prop_stat_s2
    stats = [[0,'<span style="color:#FF0000;">未承認</span>'], [1, '承認済'], [2, '貸出中'], [3, '返却済'], [4, '集計済'], [5, '請求済'], [900, 'キャンセル'], [nil, '(承認不要)']]
    stat = stats.assoc(prop_stat)
    return nil if stat.blank?
    return nil if stat[1].blank?
    return stat[1].html_safe
  end
  def csv_prop_stat_s
    stats = [[0,'未承認'], [1, '承認済'], [2, '貸出中'], [3, '返却済'], [4, '集計済'], [5, '請求済'], [900, 'キャンセル'], [nil, '(承認不要)']]
    stat = stats.assoc(self.prop_stat)
    return nil if stat.blank?
    return nil if stat[1].blank?
    return stat[1].html_safe
  end

  def necessary_confirm?
    meetingroom_related?
  end

  def confirmed?
    necessary_confirm? && decoded_extra_data['confirmed'] == 1
  end

  def confirm!
    set_extra_data({'confirmed' => 1})
    self.confirmed_uid = Core.user.id if Core.user
    self.confirmed_gid = Core.user_group.id if Core.user_group
    self.confirmed_at = Time.now

    # 承認メモ発送
    #if has_mr_pm > 0 # レンタカー承認はまだ廃止されていないが簡単のため会議室の分だけ
      if AppConfig.gw.schedule_props_settings[:add_memo_send_to_announce] == 1
        add_memo_send_to = self.schedule.creator_uid
        creator = Gw::Model::Schedule.get_user(add_memo_send_to)
        ret = Gw.add_memo(add_memo_send_to, '設備予約が承認されました。', %Q(<a href="/gw/schedules/#{self.schedule.id}/show_one">予約情報の確認</a>),{:is_system => 1}) unless creator.blank?
      end
    #end
    return :confirm_done
  end

  def unconfirm!
    set_extra_data({'confirmed' => nil})
    self.confirmed_uid = nil
    self.confirmed_gid = nil
    self.confirmed_at = nil
    return :unconfirm_done
  end

  def confirmed_label
    if necessary_confirm?
       cancelled? ? 'キャンセル' : confirmed? ? '承認済' : '<span style="color:red;">未承認</span>'
    else
      ''
    end
  end

  def rented?
    decoded_extra_data['rented'] == 1
  end

  def rent!
    set_extra_data({'rented' => 1})
    self.rented_uid = Core.user.id if Core.user
    self.rented_gid = Core.user_group.id if Core.user_group
    self.rented_at = Time.now
    return :rent_done
  end

  def unrent!
    set_extra_data({'rented' => nil})
    self.rented_uid = nil
    self.rented_gid = nil
    self.rented_at = nil
    return :unrent_done
  end

  def someone_renting_currently?
    self.class.where(prop_id: self.prop_id, prop_type: self.prop_type)
      .where(%(extra_data like '%"rented":1%' and extra_data not like '%"returned":1%'))
      .exists?
  end

  def returned?
    decoded_extra_data['returned'] == 1
  end

  def return!
    set_extra_data({'returned' => 1})
    self.returned_uid = Core.user.id if Core.user
    self.returned_gid = Core.user_group.id if Core.user_group
    self.returned_at = Time.now
    return :return_done
  end

  def unreturn!
    set_extra_data({'returned' => nil})
    self.returned_uid = nil
    self.returned_gid = nil
    self.returned_at  = nil
    return :unreturn_done
  end

  def summarized?
    returned? && prop_extra_pm_actual && prop_extra_pm_actual.summaries_state == "1"
  end

  def billed?
    summarized? && prop_extra_pm_actual && prop_extra_pm_actual.bill_state == "1"
  end

  def cancellable?
    case
    when self.rentcar_related?
      return true
    when self.meetingroom_related?
      return false unless self.schedule
      (self.schedule.schedule_events.blank? || !self.schedule.schedule_events.approved_or_opened?) && self.schedule.guide_state.to_i <= 1
    else
      return true
    end
  end

  def cancelled?
    decoded_extra_data['cancelled'] == 1
  end

  def cancell!
    set_extra_data({'cancelled' => 1})
    self.cancelled_uid = Core.user.id if Core.user
    self.cancelled_gid = Core.user_group.id if Core.user_group
    self.cancelled_at = Time.now
    return :cancel_done
  end

  def other_schedule_not_duplicate?
    rent_item_flg = true
    prop_join = "inner join gw_schedule_props on gw_schedules.id = gw_schedule_props.schedule_id"
    st_at = "#{schedule.st_at.strftime("%Y-%m-%d %H:%M")}"
    ed_at = "#{schedule.ed_at.strftime("%Y-%m-%d %H:%M")}"

    cond_results_shar = " and (extra_data is null or extra_data not like '%\"cancelled\":1%')" +
      " and (schedule_repeat_id <> '#{schedule.schedule_repeat_id}' or schedule_repeat_id is null)" +
      " and ( (gw_schedule_props.st_at <= '#{st_at}' and gw_schedule_props.ed_at > '#{st_at}' )" +
      " or (gw_schedule_props.st_at < '#{ed_at}' and gw_schedule_props.ed_at >= '#{ed_at}' )" +
      " or ('#{st_at}' <= gw_schedule_props.st_at and gw_schedule_props.st_at < '#{ed_at}') )"

    cond_actual_shar = " and (extra_data is null or extra_data not like '%\"cancelled\":1%')" +
      " and schedule_repeat_id = '#{schedule.schedule_repeat_id}'" +
      " and ( (gw_schedule_props.st_at <= '#{st_at}' and gw_schedule_props.ed_at > '#{st_at}' )" +
      " or (gw_schedule_props.st_at < '#{ed_at}' and gw_schedule_props.ed_at >= '#{ed_at}' )" +
      " or ('#{st_at}' <= gw_schedule_props.st_at and gw_schedule_props.st_at < '#{ed_at}') )"

    rent_item = Gw::Schedule.joins(prop_join).where.not(id: schedule.id).where("prop_type='#{prop_type}' and prop_id='#{prop_id}'" + cond_results_shar)
    dump rent_item.to_sql
    rent_item_flg = false if rent_item.present?


    if !schedule.schedule_repeat_id.blank?
      rent_item = Gw::Schedule.joins(prop_join).where.not(id: schedule.id).where("prop_type='#{prop_type}'" + cond_actual_shar)
      rent_item.each { |ritem|
        rent_item_flg = false if ritem.is_actual?
      }
    end
    dump rent_item_flg
    return rent_item_flg
  end

  def uncancell!
    set_extra_data({'cancelled' => nil})
    self.cancelled_uid = nil
    self.cancelled_gid = nil
    self.cancelled_at = nil
    return :uncancel_done
  end

  def cancelled_user_name
    if cancelled?
      cancelled_user ? cancelled_user.name : '自動キャンセル'
    else
      ''
    end
  end

  def prop_stat
    case self.prop_type
    when "Gw::PropRentcar"
      ret = self.cancelled? ? 900 :
        self.prop_extra_pm_rentcar_actual.nil?  ? nil :
        self.billed? ? 5 :
        self.summarized? ? 4 :
        self.returned? ? 3 :
        self.rented? ? 2 : 999
      raise if ret == 999
      return ret
    when "Gw::PropMeetingroom"
      !self.necessary_confirm? ? nil :
        self.cancelled? ? 900 :
        self.billed? ? 5 :
        self.summarized? ? 4 :
        self.returned? ? 3 :
        self.rented? ? 2 :
        self.confirmed? ? 1 : 0
    when "Gw::PropOther"
      ret = self.cancelled? ? 900 :
        self.returned? ? 3 :
        self.rented? ? 2 : nil
      return ret
    else
      nil
    end
  end

  def self.get_prop_state_str(state_no = nil)
    return '' if state_no.blank?
    if state_no == 900
      return 'キャンセル'
    elsif state_no == 5
      return '請求'
    elsif state_no == 4
      return '集計'
    elsif state_no == 3
      return '返却'
    elsif state_no == 2
      return '貸出'
    elsif state_no == 1
      return '承認'
    end
  end

  def prop_stat_category_id
    case self.prop_type
    when "Gw::PropRentcar"
      self.cancelled? ? 900 :
        self.returned? ? 3 :
        self.rented? ? 2 : 1
    when "Gw::PropMeetingroom"
      self.cancelled? ? 900 :
        self.returned? ? 3 :
        self.rented? ? 2 :
        self.confirmed? ? 1 : 0
    when "Gw::PropOther"
      self.cancelled? ? 900 :
        self.returned? ? 3 :
        self.rented? ? 2 : nil
    else
      nil
    end
  end

  def self.get_extra_classes(genre, options={})
    user = options[:user] || Core.user
    prop_classes_raw = AppConfig.gw.prop_extra_classes
    prop_classes = {}
    prop_classes = prop_classes_raw[genre] if !genre.nil? && !prop_classes_raw.nil? && !prop_classes_raw[genre].nil?
    ret = prop_classes.dup
    prop_classes.keys.select{|x| !user.has_role?("gw_props/#{x}") && !Gw.is_admin_admin? } .each do |k|
      ret.delete k
    end if options[:ignore_role].nil?
    return ret
  end
  def set_extra_data(set_data, options={})
    set_data_h = set_data.is_a?(Hash) ? set_data : JSON.parse(s_from)
    if nz(options[:override],0) != 0
      _extra_data = set_data_h
    else
      _extra_data = decoded_extra_data
      _extra_data.merge! set_data_h
    end
    _extra_data.delete_if{|k,v|v.nil?}
    self.extra_data = _extra_data.blank? ? nil : _extra_data.to_json
  end

  def _name
    self.prop.name
  end

  alias :_prop_name :_name

  def _owner
    self.schedule.owner_uname
  end

  def _subscriber
    self.schedule.owner_gname
  end

  def _prop_stat
    self.prop_stat_s
  end

  def is_kanzai?
    case self.prop_type
    when "Gw::PropMeetingroom"
      return 1
    when "Gw::PropRentcar"
      return 2
    when "Gw::PropOther"
      return 3
    else
      return 4
    end
  end


  def self.is_prop_edit?(prop_id, genre, options = {})
    if options.key?(:is_gw_admin)
      is_gw_admin = options[:is_gw_admin]
    else
      is_gw_admin = Gw.is_admin_admin?
    end

    flg = true

    if options[:prop].blank?
      prop = Gw::PropOther.find(prop_id)
    else
      prop = options[:prop]
    end

    unless prop.blank?
      if !is_gw_admin
        flg = Gw::PropOtherRole.is_edit?(prop_id) && (prop.reserved_state == 1 || prop.delete_state == 0)
      end
      if prop.reserved_state == 0 || prop.delete_state == 1
        flg = false
      end
    else
      flg = false
    end

    return flg
  end

  def self.getajax(_params, _options={})
    begin
      params = HashWithIndifferentAccess.new(_params)
      options = HashWithIndifferentAccess.new(_options)
      genre_raw = params['s_genre']
      admin = Gw.is_admin_admin?
      genre, cls, be = genre_raw.split ':'
      type_id =  nz(_params['type_id'],"")
      st_at = Gw.to_time(params['st_at']) rescue nil
      ed_at = Gw.to_time(params['ed_at']) rescue nil
      case genre
      when nil
        item = {:errors=>'施設指定が異常です'}
      when 'rentcar', 'meetingroom', 'other'
        model_name = "Gw::Prop#{genre.capitalize}"
        model = eval(model_name)
        if st_at.nil? || ed_at.nil? || st_at >= ed_at
          item = {:errors=>'日付が異常です'}
        else
          @index_order = 'extra_flag, sort_no, gid, name'

          cond_props_within_terms = "SELECT distinct prop_id FROM gw_schedules"
          cond_props_within_terms += " left join gw_schedule_props on gw_schedules.id =  gw_schedule_props.schedule_id"
          cond_props_within_terms += " where"
          cond_props_within_terms += " gw_schedules.id <> #{params[:schedule_id].to_i} and " unless params[:schedule_id].blank?
          cond_props_within_terms += " gw_schedules.ed_at >= '#{Gw.datetime_str(st_at)}'"
          cond_props_within_terms += " and gw_schedules.st_at < '#{Gw.datetime_str(ed_at)}'"
          cond_props_within_terms += " and prop_type = '#{model_name}'"
          cond_props_within_terms += " and (gw_schedule_props.extra_data is null or gw_schedule_props.extra_data not like '%\"cancelled\":1%')"
          cond_props_within_terms += " order by prop_id"
          cond = "coalesce(extra_flag,'other')='#{cls}' and piwt.prop_id is null"
          cond += " and ( gw_prop_#{genre}s.delete_state = 0 or gw_prop_#{genre}s.delete_state IS NULL ) and gw_prop_#{genre}s.reserved_state = 1"
          joins = "left join (#{cond_props_within_terms}) piwt on gw_prop_#{genre}s.id = piwt.prop_id"

          if genre == "other"
            if prop_type = Gw::PropType.where(:id => be).first
              cond += " and gw_prop_#{genre}s.type_id = #{prop_type.id}"
            end
            item = model.joins(joins).where(cond).order("type_id, gid, sort_no, name")
              .preload(:owner_group, :prop_other_roles)
              .select {|item| admin || item.is_edit? }
              .map {|item| [genre, item.id, "(#{item.owner_group.try(:code)})#{item.name}", item.gname] }
          else
            item = model.joins(joins).where(cond).order(@index_order)
              .map {|item| [genre, item.id, item.name, item.gname] }
          end
          item = {:errors=>'該当する候補がありません'} if item.blank?
        end
      end
      return item
    rescue => e
      dump e
      return {:errors=>'不明なエラーが発生しました'}
    end
  end

  private

  def decoded_extra_data
    return @decoded_extra_data if defined? @decoded_extra_data
    @decoded_extra_data = JSON.parse(self.extra_data) rescue {}
  end

  def destroy_actual
    self.prop_extra_pm_rentcar_actual.destroy if self.prop_extra_pm_rentcar_actual
    self.prop_extra_pm_meetingroom_actual.destroy if self.prop_extra_pm_meetingroom_actual
  end
end
