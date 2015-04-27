require 'csv'
class Gw::ScheduleEvent < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :gid, :class_name => 'System::Group'

  belongs_to :parent_group, :foreign_key => :parent_gid, :class_name => 'System::Group'
  belongs_to :parent_group_history, :foreign_key => :parent_gid, :class_name => 'System::GroupHistory'

  belongs_to :week_approval_user, :foreign_key => :week_approval_uid, :class_name => 'System::User'
  belongs_to :week_approval_group, :foreign_key => :week_approval_gid, :class_name => 'System::Group'
  belongs_to :week_open_user, :foreign_key => :week_open_uid, :class_name => 'System::User'
  belongs_to :week_open_group, :foreign_key => :week_open_gid, :class_name => 'System::Group'
  belongs_to :month_approval_user, :foreign_key => :month_approval_uid, :class_name => 'System::User'
  belongs_to :month_approval_group, :foreign_key => :month_approval_gid, :class_name => 'System::Group'
  belongs_to :month_open_user, :foreign_key => :month_open_uid, :class_name => 'System::User'
  belongs_to :month_open_group, :foreign_key => :month_open_gid, :class_name => 'System::Group'

  before_save :set_user_and_group
  before_save :set_sort_id

  scope :with_week_opened, -> { where(event_week: 1, week_open: 1) }
  scope :with_month_opened, -> { where(event_month: 1, month_open: 1) }
  scope :scheduled_between, ->(st_date, ed_date) {
    where(arel_table[:ed_at].gteq(st_date)).where(arel_table[:st_at].lt(ed_date + 1))
  }
  scope :start_at_between, ->(st_date, ed_date) {
    where(arel_table[:st_at].gteq(st_date)).where(arel_table[:st_at].lt(ed_date + 1))
  }

  def approval_user(pattern)
    send("#{pattern}_approval_uname")
  end

  def approval_group(pattern)
    send("#{pattern}_approval_gname")
  end

  def approval(pattern)
    read_attribute("#{pattern}_approval")
  end

  def approved_at(pattern)
    read_attribute("#{pattern}_approved_at")
  end

  def open_user(pattern)
    send("#{pattern}_open_uname")
  end

  def open_group(pattern)
    send("#{pattern}_open_gname")
  end

  def open(pattern)
    read_attribute("#{pattern}_open")
  end

  def opened_at(pattern)
    read_attribute("#{pattern}_opened_at")
  end

  def approved?(pattern)
    approval(pattern) == 1
  end

  def opened?(pattern)
    open(pattern) == 1
  end

  def approved_or_opened?
    week_approval == 1 || week_open == 1 || month_approval == 1 || month_open == 1
  end

  def event_kind
    # 行事予定の種別を判定する
    # 週間・月間ともにチェックがある場合：3
    # 月間のみチェックがある場合：2
    # 週間のみチェックがある場合：1
    # 週間・月間ともにチェックがない場合：0

    if event_month == 1 && event_week == 1
      3
    elsif event_month == 1
      2
    elsif event_week == 1
      1
    else
      0
    end
  end

  def event_kind_str
    case event_kind
    when 1
      "週間"
    when 2
      "月間"
    when 3
      "週間/月間"
    else
      ""
    end
  end

  def event_master_auth?
    # ログインユーザーが、その行事の主管課かどうか確認
    # 承認時に確認のため使用
    range_gids = Gw::ScheduleEventMaster.edit_auth_range_gids()
    range_parent_gids = Gw::ScheduleEventMaster.edit_auth_range_parent_gids()

    gid = self.gid
    parent_gid = self.parent_gid

    gid_ret = range_gids.rassoc(gid) if range_gids.length > 0
    return true unless gid_ret.blank?

    pgid_ret = range_parent_gids.rassoc(parent_gid) if range_parent_gids.length > 0
    return true unless pgid_ret.blank?

    return false # 検索して無ければfalse

  end

  def self.is_group_event_master_auth?(gid = Core.user.groups[0].id)
    # 指定したグループIDが、ログインユーザーの主管課かどうか確認する。
    group = System::Group.where(:id => gid).first
    return false if group.blank?
    parent_gid = group.parent_id

    if Gw::ScheduleEventMaster.is_ev_management?
      range_gids = Gw::ScheduleEventMaster.range_gids(Core.user.id, {:func_name => 'gw_event'})
      range_parent_gids = Gw::ScheduleEventMaster.range_parent_gids(Core.user.id, {:func_name => 'gw_event'})

      gid_ret = range_gids.rassoc(gid) if range_gids.length > 0
      return true unless gid_ret.blank?

      pgid_ret = range_parent_gids.rassoc(parent_gid) if range_parent_gids.length > 0
      return true unless pgid_ret.blank?

      return false # 検索して無ければfalse
    else
      return false
    end
  end

  def get_at_str(at_pattern = :st_at)
    # 時間の表示を取得する
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    if at_pattern == :st_at
      at = self.st_at
    elsif at_pattern == :ed_at
      at = self.ed_at
    end

    if at.blank?
      return ""
    end

    ret = "#{at.strftime('%Y-%m-%d')} （#{wdays[at.wday]}）"
    if self.allday == 1
      ret += " 時間未定"
    elsif self.allday == 2
      ret += " 終日"
    else
      ret += " #{at.strftime('%H:%M')}"
    end
    return ret
  end

  def self.is_ev_admin?(user = Core.user)
    user.has_role?('gw_event/admin')
  end

  def self.is_csv_put_user?(user = Core.user)
    user.has_role?('gw_event/csv_put_user')
  end

  def self.is_ev_operator?(user = Core.user)
    is_ev_admin?(user) || Gw::ScheduleEventMaster.is_ev_management_edit_auth?(user.id)
  end

  def self.is_ev_reader?(user = Core.user)
    is_ev_admin?(user) || Gw::ScheduleEventMaster.is_ev_management?(user.id)
  end

  def self.select_st_at_week_options(is_ev_reader)
    week_start = Time.now.beginning_of_week
    items = self.where(event_week: 1).where(arel_table[:st_at].gteq(week_start))
    items = items.where(gid: Core.user.id) unless is_ev_reader
    items = items.select("YEARWEEK(st_at, 3) as yearweek")
      .group("YEARWEEK(st_at, 3)")
      .order("YEARWEEK(st_at, 3)")

    items.inject([['すべて','']]) do |arr, item|
      d = Date.commercial(item.yearweek.to_s[0..3].to_i, item.yearweek.to_s[4..5].to_i) rescue nil
      arr << ["#{d.strftime('%Y-%m-%d')}の週", d.strftime('%Y-%m-%d')] if d
    end
  end

  def self.select_st_at_month_options(is_ev_reader)
    month_start = Time.new('2016-01-01').beginning_of_month
    items = self.where(event_month: 1).where(arel_table[:st_at].gteq(month_start))
    items = items.where(gid: Core.user.id) unless is_ev_reader
    items = items.select("DATE_FORMAT(st_at, '%Y-%m-01') as month, DATE_FORMAT(st_at, '%Y年%m月') as month_str")
      .group("DATE_FORMAT(st_at, '%Y-%m-01')")
      .order("DATE_FORMAT(st_at, '%Y-%m-01')")

    items.inject([['すべて','']]) {|arr, item| arr << [item.month_str, item.month] }
  end

  def self.select_parent_gid_options(pattern = 'week')
    items = pattern == 'week' ? self.where(event_week: 1) : self.where(event_month: 1)
    items = items.select(:parent_gid).group(:parent_gid)
    System::GroupHistory.where(id: items.map(&:parent_gid)).order(:sort_no).all.map{|g| [g.name, g.id]}
  end

  def self.week_start(day = Date.today)
    day = day.to_date # 念のため、日付型に変更
    case day.wday
    when 0 # 日曜日
      cnt = 7 # 月曜日を導くため、現在の日付から引く日数
    else
      cnt = day.wday
    end
    week_start_at = day - cnt + 1 # 常に月曜日から始まるようにする。
    return week_start_at
  end

  def self.parent_gid_state?(parent_gid)
    parent_gid.to_i.in?([11, 12, 13, 15, 16])
  end

  def event_display(pattern = "week", options={})
    str = ""
    if pattern == "week" # 週表示
      if self.allday == 1
        str += "（時間未定）\n"
      elsif self.allday == 2
        str = ""
      else
        str += "#{self.st_at.hour}:#{self.st_at.strftime("%M")}～\n"
      end
      str += self.title
      if !self.place.blank? || !self.event_word.blank?
        str += "\n（#{self.place} #{self.event_word}）"
      end
    else # 月表示
      str += self.title + "　"

      if self.allday.blank? ||  self.allday == 0
        time_str = "#{self.st_at.hour}:#{self.st_at.strftime("%M")}～　"
      elsif self.allday == 1
        time_str = "時間未定　"
      else
        time_str = ""
      end

      if time_str.blank? && self.place.blank? && self.event_word.blank?
        parent_str = ""
      else
        parent_str = "（#{time_str}#{self.place}#{self.event_word}）"
      end

      str += "#{parent_str} "
      if Gw::ScheduleEvent.parent_gid_state?(self.parent_gid)
        group = System::Group.where(:id => self.parent_gid).first
        group_name = group.name
      else
        group_name = self.schedule.owner_gname
      end
      str += "<#{group_name}>"
    end
    return str
  end

  def get_event_connection_items
    array = [self]
    array += self.schedule.get_repeat_and_parent_items.map(&:schedule_events) if self.schedule
    array.compact.uniq
  end

  def approve!(pattern, user = Core.user)
    ret = true
    transaction do
      attrs = {
        "#{pattern}_approval" => 1,
        "#{pattern}_approved_at" => Time.now,
        "#{pattern}_approval_uid" => user.id,
        "#{pattern}_approval_ucode" => user.code,
        "#{pattern}_approval_uname" => user.name,
        "#{pattern}_approval_gid" => user.groups.first.try(:id),
        "#{pattern}_approval_gcode" => user.groups.first.try(:code),
        "#{pattern}_approval_gname" => user.groups.first.try(:name)
      }
      get_event_connection_items.each do |item|
        item.attributes = attrs
        ret &&= item.save
      end
    end
    ret
  end

  def unapprove!(pattern)
    ret = true
    transaction do
      attrs = {
        "#{pattern}_approval" => 0,
        "#{pattern}_approved_at" => nil,
        "#{pattern}_approval_uid" => nil,
        "#{pattern}_approval_ucode" => nil,
        "#{pattern}_approval_uname" => nil,
        "#{pattern}_approval_gid" => nil,
        "#{pattern}_approval_gcode" => nil,
        "#{pattern}_approval_gname" => nil
      }
      get_event_connection_items.each do |item|
        item.attributes = attrs
        ret &&= item.save
      end
    end
    ret
  end

  def open!(pattern, user = Core.user)
    ret = true
    transaction do
      attrs = {
        "#{pattern}_open" => 1,
        "#{pattern}_opened_at" => Time.now,
        "#{pattern}_open_uid" => user.id,
        "#{pattern}_open_ucode" => user.code,
        "#{pattern}_open_uname" => user.name,
        "#{pattern}_open_gid" => user.groups.first.try(:id),
        "#{pattern}_open_gcode" => user.groups.first.try(:code),
        "#{pattern}_open_gname" => user.groups.first.try(:name)
      }
      get_event_connection_items.each do |item|
        item.attributes = attrs
        ret &&= item.save
      end
    end
    ret
  end

  def close!(pattern)
    ret = true
    transaction do
      attrs = {
        "#{pattern}_open" => 0,
        "#{pattern}_opened_at" => nil,
        "#{pattern}_open_uid" => nil,
        "#{pattern}_open_ucode" => nil,
        "#{pattern}_open_uname" => nil,
        "#{pattern}_open_gid" => nil,
        "#{pattern}_open_gcode" => nil,
        "#{pattern}_open_gname" => nil
      }
      get_event_connection_items.each do |item|
        item.attributes = attrs
        ret &&= item.save
      end
    end
    ret
  end

  class << self
    def make_groups_from_events(items)
      groups = []
      items.each do |item|
        if Gw::ScheduleEvent.parent_gid_state?(item.parent_gid)
          group = {id: item.parent_gid, code: item.parent_gcode, name: item.parent_gname, parent_id: 1, collect_by_parent: true}
        else
          group = {id: item.gid, code: item.gcode, name: item.gname, parent_id: item.parent_gid, collect_by_parent: false}
        end
        groups << group unless groups.any?{|g| g[:id] == group[:id]}
      end
      groups
    end

    def generate_week_csv(items, groups, st_date, ed_date)
      now = Time.now

      CSV.generate(:force_quotes => true) do |csv|
        csv << [nil, "週間行事予定表（#{st_date.month}月#{st_date.day}日～#{ed_date.month}月#{ed_date.day}日）"]
        csv << [nil, nil, "#{now.month}月#{now.day}日（#{Gw.weekday(now.wday)}） #{now.hour}時現在　#{Core.user_group.name}調べ"]
        csv << [nil] + (st_date..ed_date).map{|d| "#{d.month}/#{d.day}#{Gw.weekday(d.wday)}"}
  
        groups.each do |group|
          group_events = items.select {|ev|
            ((group[:collect_by_parent] && ev.parent_gid == group[:id]) ||
            (!group[:collect_by_parent] && ev.gid == group[:id]))
          }
          next if group_events.blank?
  
          data = [group[:name]]
          st_date.upto(ed_date).each do |date|
            events = group_events.select{|ev| ev.schedule.date_between?(date)}
            if events.blank?
              data << nil
            else
              data << events.map{|ev| ev.event_display("week").gsub("\n", ' ') }.join("\n")
            end
          end
          csv << data
        end
      end
    end

    def generate_month_csv(items, st_date, ed_date)
      now = Time.now

      CSV.generate(:force_quotes => true) do |csv|
        csv << [nil, nil, "月間行事予定表（#{st_date.month}月分）"]
        csv << [nil, nil, "#{now.month}月#{now.day}日（#{Gw.weekday(now.wday)}） #{now.hour}時現在　#{Core.user_group.name}調べ"]
        csv << ["日","曜","行事名"]

        st_date.upto(ed_date) do |date|
          events = items.select {|item| item.st_at.to_date == date }
          if events.blank?
            csv << [date.day, Gw.weekday(date.wday), nil]
          else
            events.each_with_index do |event, i|
              data = i == 0 ? [date.day, Gw.weekday(date.wday)] : [nil, nil]
              data << event.event_display("month")
              csv << data
            end
          end 
        end
      end
    end
  end

  private

  def set_user_and_group
    if uid_changed? && user
      self.ucode = user.code
      self.uname = user.name
    end
    if gid_changed? && group
      self.gcode = group.code
      self.gname = group.name
    end
    if parent_gid_changed? && parent_group
      self.parent_gcode = parent_group.code
      self.parent_gname = parent_group.name
    end
  end

  def set_sort_id
    if parent_gid_changed?
      if Gw::ScheduleEvent.parent_gid_state?(self.parent_gid)
        self.sort_id = 0
      else
        self.sort_id = self.gid
      end
    end
  end
end
