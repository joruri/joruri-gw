# -*- encoding: utf-8 -*-
class Gwsub::Sb01TrainingScheduleCondition < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :training_rel   ,:foreign_key=>'training_id'     ,:class_name=>"Gwsub::Sb01Training"
  belongs_to :user_rel       ,:foreign_key=>'member_id'       ,:class_name=>"System::User"
  belongs_to :group_rel      ,:foreign_key=>'group_id'        ,:class_name=>"System::Group"
  belongs_to :prop_rel       ,:foreign_key=>'prop_id'         ,:class_name=>"Gw::PropMeetingroom"


  validates_presence_of :training_id
  validates_presence_of :members_max
  validates_numericality_of :members_max
  validates_presence_of :title
  validates_presence_of :from_at
  validates_presence_of :prop_name
  validates_length_of :prop_name,  :maximum => 70
  validate :from_end_check

  #validates_presence_of :member_id
  #validates_presence_of :prop_id, :if=>Proc.new{ |item| item.prop_kind.to_i==1}
  #validates_presence_of :extension, :if=>Proc.new{ |item| item.prop_kind.to_i==1}
  #validates_presence_of :prop_name , :unless=>Proc.new{ |item| item.prop_kind.to_i==1 or item.prop_kind.to_i==9}

  # 時刻設定
  validates_each :from_start,:from_end do |record, attr, value|
    record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank?
  end
  #validates_each :from_end do |record, attr, value|
  #  record.errors.add attr, 'は、開始時刻より後の時刻を入力して下さい。' if !value.to_s.blank? and value <= record.from_start
  #end
  def from_end_check
    from_start_str = self.from_start+':'+self.from_start_min
    from_end_str = self.from_end+':'+self.from_end_min
    self.errors.add(:from_end,"終了時刻は、開始時刻より後の時刻を入力して下さい") if from_end_str <= from_start_str
  end
  # 繰り返し設定
  validates_presence_of :repeat_flg
  validates_each :repeat_class_id do |record, attr, value|
    record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank? and record.repeat_flg.to_i==2
  end
  validates_each :repeat_weekday do |record, attr, value|
    record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank? and record.repeat_flg.to_i==2 and record.repeat_class_id.to_i==3
  end
  #validates_each :repeat_monthly,:repeat_weekday do |record, attr, value|
  #  record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank? and record.repeat_flg.to_i==2
  #end

  #当日付の登録を排除（繰り返しなし）
  validates_each :from_at,:on => :create do |record, attr, value|
    record.errors.add attr, 'は、「繰り返しなし」の場合、本日の日付では登録できません。' if !value.to_s.blank? and Gw.date_str(value) == Date.today.to_s and record.repeat_flg.to_i==1
  end
  #当日付の登録を排除（繰り返しあり）
  validates_each :to_at,:on => :create do |record, attr, value|
    record.errors.add attr, 'は、「繰り返しあり」の場合、本日の日付では登録できません。' if !value.to_s.blank? and Gw.date_str(value) == Date.today.to_s and record.repeat_flg.to_i==2
  end


  validates_each :repeat_weekday do |record, attr, value|
    record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank? and record.repeat_flg.to_i==2 and record.repeat_class_id.to_i==3
  end

  # 日付設定
  validates_each :from_at,:on => :create do |record, attr, value|
    record.errors.add attr, 'に、過去日付は指定できません。' if !value.to_s.blank? and Gw.date_str(value) < Date.today.to_s
  end
  validates_each :from_at,:to_at do |record, attr, value|
    record.errors.add attr, 'を、入力して下さい。' if value.to_s.blank? and record.repeat_flg.to_i>1
  end
  validates_each :to_at do |record, attr, value|
    record.errors.add attr, 'は、開始日より後の日付を入力して下さい。' if !value.to_s.blank? and record.repeat_flg.to_i>1 and Gw.date_common(value) <= Gw.date_common(record.from_at)
  end
  #validates_each :from_at,:to_at do |record, attr, value|
  #  record.errors.add attr, 'は予約できない日付です。' if !value.to_s.blank? and Gwsub::Sb01TrainingScheduleProp.prop_date_reservable(value)==false
  #end


  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def repeat_no
    [['なし',1],['あり',2]]
  end

  def repeat_label
    repeat_no.each {|a| return a[0] if a[1] == repeat_flg.to_i }
    return nil
  end
  def repeat_class_no
    [['毎日',1],['毎日（土日除く）',2],['毎週',3]]
  end

  def repeat_class_label
    repeat_class_no.each {|a| return a[0] if a[1] == repeat_class_id.to_i }
    return nil
  end

  def self.set_f(items)
    new_params = items
    if items[:repeat_flg].to_i ==  2
      unless items[:repeat_weekday].blank?
        new_params[:repeat_weekday] = items[:repeat_weekday].values.join(',').to_s
      end
    else
    end
    return new_params
  end

  def self.prop_kind_select
    options={:rev=>false}
    states = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_prop_kind',options
    return states
  end
  def self.prop_kind_show(kind=9)
    options={:rev=>true}
    states = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_prop_kind',options
    show = states.assoc(kind)
    return nil if show.blank?
    return show[1]
  end

  def self.repeat_flgs(all=nil)
    states = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_repeat_flag'
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.repeat_rules(all=nil)
    states = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_repeat_rule'
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.monthly_show(repeat_monthly)
    return nil if repeat_monthly.to_s.blank?
    repeats = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_repeat_monthly_checkboxes',:rev=>true
    show_str = []
    show_key = repeat_monthly.split(',')
    show_key.each do |ax|
      show_str << (repeats.assoc(ax.to_i))[1]
    end
    return show_str.join('：')
  end
  def self.monthly_flg(repeat_monthly)
    return nil if repeat_monthly.to_s.blank?
    show_key = repeat_monthly.split(',')
    xh = []
    show_key.each do |value|
      xh << value.to_i
    end
    return xh.join(':')
  end

  def self.weekday_show(repeat_weekday)
    return nil if repeat_weekday.to_s.blank?
    repeats = Gw.yaml_to_array_for_select 'gwsub_sb01_training_schedule_repeat_weekday_checkboxes',:rev=>true
    show_str = []
    show_key = repeat_weekday.split(',')
    show_key.each do |ax|
      show_str << (repeats.assoc(ax.to_i))[1]
    end
    return show_str.join('：')
  end
  def self.weekday_flg(repeat_weekday)
    return nil if repeat_weekday.to_s.blank?
    show_key = repeat_weekday.split(',')
    xh = []
    show_key.each do |value|
      xh << value.to_i
    end
    return xh.join(':')
  end

  def self.repeat_dates(ts)
    repeats = []
    return repeats if ts.blank?
    #[研修名、開始日時・終了日時・会議室id・登録者（ログインユーザー）id]
    case ts.repeat_flg
    when '1'
      # 繰返し無し
      date_sta = Gw.date_str(ts.from_at) + ' ' + ts.from_start + ':' + ts.from_start_min
      date_end = Gw.date_str(ts.from_at) + ' ' + ts.from_end + ':' + ts.from_end_min
      repeats << [ts.title,date_sta,date_end,ts.prop_id,ts.member_id,ts.members_max]
    when '2'
      # 週・曜日指定
      # 終了日まで、指定日を判定しながら登録
      select_dates = []
      #monthly = ts.repeat_monthly.split(',')
      weekday = ts.repeat_weekday.split(',') if ts.repeat_class_id == 3
      start_at = Gw.get_parsed_date(ts.from_at)
      end_at = Gw.get_parsed_date(ts.to_at)
      work_day = start_at
      while work_day <= end_at
        check_day = Gw.get_parsed_date(work_day)
        if check_day.blank?
          # 日付チェックでエラーの時は次へ
          work_day = work_day + 24*60*60
          next
        end
        if ts.repeat_class_id == 1
          select_dates << Gw.date_str(work_day)
        elsif ts.repeat_class_id == 2
          w = work_day.wday
          if (w == 0 || w == 6)
            work_day = work_day + 24*60*60
            next
          end
          select_dates << Gw.date_str(work_day)
        else
          w = work_day.wday
          # 曜日が対象外の場合は、次の日付へ
          if weekday.index(w.to_s)== nil
            work_day = work_day + 24*60*60
            next
          end
           select_dates << Gw.date_str(work_day)
        end
          work_day = work_day + 24*60*60
      end
      date_range_end = Gw.date_str(ts.to_at)
      date_target = Gw.date_str(ts.from_at)
      while date_target <= date_range_end
        if select_dates.index(date_target).nil?
        else
          date_sta = date_target + ' ' + ts.from_start + ':' + ts.from_start_min
          date_end = date_target + ' ' + ts.from_end + ':' + ts.from_end_min
          repeats << [ts.title,date_sta,date_end,ts.prop_name,ts.member_id,ts.members_max]
        end
        dates = date_target.split('-')
        date_next = Date.new(dates[0].to_i,dates[1].to_i,dates[2].to_i) + 1
        date_target = date_next.to_s
      end
    else
    end
    return repeats
  end

  #
  def self.get_select_prop_meetingroom
  # 管財会議室選択
    room1 = Gw::PropMeetingroom.new
    room1.extra_flag = 'pm'
    room1.order   'extra_flag, sort_no, gid, name'
    rooms = room1.find(:all)
    selects=[]
    rooms.each do |x|
      selects << [ x.name, x.id ]
    end
    return selects
#    _conditions = "extra_flag = 'pm'"
#    return Gw::PropMeetingroom.find(:all, :conditions=>_conditions, :select=>"id,name", :order=>'extra_flag, sort_no, gid, name').map{|x| [ x.name, x.id ]}
  end
  # 研修申込受付　開催時刻選択
  def self.select_times
    range = Gw.yaml_to_array_for_select 'gwsub_sb01_training_time_range'
    selects = []
    count = range[0][0].to_i
    while count <= range[1][0].to_i
      #if count.to_i == 12
        # 研修は、12時開始をスキップ
      #else
        #time_str = sprintf("%02d",count)+":00"
        time_str = sprintf("%02d",count)
        selects << [time_str,time_str]
      #end
      count = count + 1
    end
    return selects
  end
  # 研修申込受付　終了時刻選択
  def self.select_times_end
    range = Gw.yaml_to_array_for_select 'gwsub_sb01_training_time_range_end'
    selects = []
    count = range[0][0].to_i
    while count <= range[1][0].to_i
      #if count.to_i == 13
        # 研修は、13時終了をスキップ
      #else
        #time_str = sprintf("%02d",count)+":00"
        time_str = sprintf("%02d",count)
        selects << [time_str,time_str]
      #end
      count = count + 1
    end
    return selects
  end
  # 研修申込受付　分選択（15分ごと
  def self.select_times_min
    selects = [['00','00'],['15','15'],['30','30'],['45','45']]
    #selects = [['すべて',0]] + selects if all=='all'
    return selects
  end
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:title,:members_max
      when 'c_id'
        search_equal v,:id unless (v.to_s == '0' || v.to_s == nil)
      when 't_id'
        search_equal v,:training_id unless (v.to_s == '0' || v.to_s == nil)
      when 'm_id'
        search_equal v,:member_id unless (v.to_s == '0' || v.to_s == nil)
      when 'p_id'
        search_equal v,:prop_id unless (v.to_s == '0' || v.to_s == nil)
      end
    end if params.size != 0

    return self
  end

#  def self.drop_create_table
#    connect = self.connection()
#    drop_query = "DROP TABLE IF EXISTS `gwsub_sb01_training_conditions` ;"
#    connect.execute(drop_query)
#    create_query = "CREATE TABLE `gwsub_sb01_training_conditions` (
#      `id`                  int(11) NOT NULL auto_increment,
#      `training_id`         int(11) default NULL,
#      `members_max`         int(11) default NULL,
#      `title`               text default NULL,
#      `from_at`             datetime default NULL,
#      `from_start`          text default NULL,
#      `from_end`            text default NULL,
#      `member_id`           int(11) default NULL,
#      `group_id`            int(11) default NULL,
#      `prop_id`             int(11) default NULL,
#      `repeat_flg`          text default NULL,
#      `repeat_monthly`      text default NULL,
#      `repeat_weekday`      text default NULL,
#      `to_at`               datetime default NULL,
#      `state`               text default NULL,
#      `updated_at`          datetime default NULL,
#      `updated_user`        text default NULL,
#      `updated_group`       text default NULL,
#      `created_at`          datetime default NULL,
#      `created_user`        text default NULL,
#      `created_group`       text default NULL,
#      PRIMARY KEY  (`id`)
#    ) DEFAULT CHARSET=utf8;"
#    connect.execute(create_query)
#    return
#  end
end
