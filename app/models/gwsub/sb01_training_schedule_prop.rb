class Gwsub::Sb01TrainingScheduleProp < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :training_rel   ,:foreign_key=>'training_id'     ,:class_name=>"Gwsub::Sb01Training"
  belongs_to :tc_rel         ,:foreign_key=>'condition_id'    ,:class_name=>"Gwsub::Sb01TrainingScheduleCondition"
  belongs_to :user_rel       ,:foreign_key=>'member_id'       ,:class_name=>"System::User"
  belongs_to :group_rel      ,:foreign_key=>'group_id'        ,:class_name=>"System::Group"
  belongs_to :prop_rel       ,:foreign_key=>'prop_id'         ,:class_name=>"Gw::PropMeetingroom"
  belongs_to :schedule       ,:foreign_key=>'schedule_id'     ,:class_name=>"Gw::Schedule"

  validates_presence_of :training_id
  validates_presence_of :member_id
#  validates_presence_of :group_id
  #validates_presence_of :prop_id
  validates_presence_of :members_max

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.prop_date_reservable(st_at1=Time.now)
    # 休日判定
#pp st_at1
    if st_at1.is_a?(String)
      st_at  = st_at1
    else
      st_at  = Gw.date_common(st_at1)
      return false if st_at.blank?
    end
    holidays  =Gw::Holiday.find(:all,:order=>"st_at").map{|x| x.st_at.strftime("%Y-%m-%d %H:%M:%S")}
    st_day  = st_at.split(' ')
    st_date = st_day[0].split('-')
    st_time = st_day[1].split(':')
    check_day = st_day[0] + " 00:00:00"
    date_type = holidays.index(check_day)
    # 予約日が休日の時はfalse
    return false  unless  date_type.blank?
    # 曜日判定
    day = Date::new(st_date[0].to_i , st_date[1].to_i , st_date[2].to_i)
    youbi = day.wday
    # 土日はfalse
    return false if youbi.to_i==6
    return false if youbi.to_i==0
    # 休日以外
    # 予約可能日の上限
    #after_today = Gwsub::Sb01TrainingScheduleProp.prop_reservation_last
    #if after_today.blank?
      # 上限なし？
    #  return true
    #end
    #max_date  = Date.today + after_today.to_i
#pp day,max_date
    #if day > max_date
    #  return false
    #end
    return true
  end

  def self.prop_reservation_last
    # 操作可能期限（何日先まで）を取得
    options={:rev=>true}
    pm_props_conditions = Gw.yaml_to_array_for_select 'sb01_props_regist_operation_range',options
    after_today = pm_props_conditions.assoc('restrict_regist_with_pm_reservation_after')
    return nil if after_today.blank?
    return after_today[1]
  end
  def self.prop_time_range
    # 操作可能時間帯を取得
    options={:rev=>true}
    pm_props_conditions = Gw.yaml_to_array_for_select 'sb01_props_regist_operation_range',options
    time_range = pm_props_conditions.assoc('restrict_regist_with_pm_operation_time')
    return nil if time_range.blank?
    return time_range[1]
  end

  def self.prop_time_reservable
    # 休日の予約操作は不可
    return false if Gwsub::Sb01TrainingScheduleProp.prop_date_reservable==false
    # 予約操作可能時間帯のチェック
    time_range = Gwsub::Sb01TrainingScheduleProp.prop_time_range
    # 運用制限がなければ true
    return true if time_range.blank?

    times = time_range.split('-')
    from_at = times[0]
    to_at   = times[1]
    current_time  = Time.now.strftime("%HH:%MM")
    # 現在時刻が範囲外のときは false
    return false if current_time < from_at
    return false if current_time > to_at
    return true
  end

  def self.schedule_props_link_check(s_id=nil,p_id=nil,prop_kind=9)
    # スケジュールidが未設定はリンクなし
    return false if s_id.blank?
    # 会議室idが未設定
#    if p_id.blank?
    if p_id.to_i==0
      if prop_kind.to_i==1
        # 管財課会議室の場合はリンクなし
        return false
      else
        # 管財課会議室以外はリンクあり
        return true
      end
    end
#    return false if p_id.blank?
    props_cond = "schedule_id=#{s_id} and prop_id=#{p_id} and prop_type='Gw::PropMeetingroom' "
    props_count = Gw::ScheduleProp.count(:all,:conditions=>props_cond)
    # 会議室予約が削除されている場合リンクなし
    return false if props_count==0
    return true
  end

  def self.state_show(state)
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_props_state'
    states = []
    list2.each do |value , key|
      states << [key,value]
    end
    show = states.assoc(state.to_i)
#pp state,states,show
    return nil if show.blank?
    return show[1]
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:title,:members_max
      when 't_id'
        search_id v,:training_id unless (v.to_s == '0' || v.to_s == nil)
      when 'c_id'
        search_id v,:condition_id unless (v.to_s == '0' || v.to_s == nil)
      when 's_id'
        search_id v,:schedule_id unless (v.to_s == '0' || v.to_s == nil)
      when 'p_id'
        search_id v,:prop_id unless (v.to_s == '0' || v.to_s == nil)
      when 'm_id'
        search_id v,:member_id unless (v.to_s == '0' || v.to_s == nil)
      when 'g_id'
        search_id v,:group_id unless (v.to_s == '0' || v.to_s == nil)
      end
    end if params.size != 0

    return self
  end

end
