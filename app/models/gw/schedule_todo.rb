class Gw::ScheduleTodo < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'

  scope :only_finished, -> { where(is_finished: 1) }
  scope :only_unfinished, -> { where(is_finished: 0) }

  scope :search_with_params, ->(params) {
    rel = all
    case params[:s_finished]
    when "1"
      rel = rel.only_unfinished
    when "2"
      rel = rel.only_finished
    end
    rel
  }
  scope :index_order_with_params, ->(params) {
    rel = all
    if params[:sort_keys] =~ /\A(.+) (.+)\z/
      case $1
      when 'ed_at'
        schedules = Gw::Schedule.arel_table
        todos = arel_table
        rel = rel.order(todos[:todo_ed_at_indefinite].send($2), schedules[:ed_at].send($2))
      when 'title'
        schedules = Gw::Schedule.arel_table
        rel = rel.order(schedules[:title].send($2))
      else
        rel = rel.order($1 => $2.to_sym)
      end
    end
    rel = rel.order(todo_ed_at_indefinite: :asc, is_finished: :asc, ed_at: :asc)
  }

  scope :todos_for_reminder, ->(user = Core.user, property) {
    rel = where.not(ed_at: nil, todo_ed_at_id: 2)
      .joins(:schedule).merge(Gw::Schedule.with_participant(user))

    cond1 = finished_todos_for_reminder(property.todos['finish_todos_display'].to_i)
    cond2 = unfinished_todos_for_reminder(property.todos['unfinish_todos_display_start'].to_i, property.todos['unfinish_todos_display_end'].to_i)
    rel.where(cond1.where_values.reduce(:and).or(cond2.where_values.reduce(:and)))
  }
  scope :finished_todos_for_reminder, ->(finish_st) {
    today = Date.today
    st = today - finish_st + 1
    ed = today + 1
    where(is_finished: 1).where(arel_table[:ed_at].in(st..ed))
  }
  scope :unfinished_todos_for_reminder, ->(unfinish_st, unfinish_ed) {
    today = st = ed = Date.today
    if unfinish_st == 0
      st = today
      ed = today + unfinish_ed
    elsif unfinish_ed == 0
      st = today - unfinish_st + 1
      ed = today + 1
    else
      st = today - unfinish_st + 1
      ed = today + unfinish_ed
    end
    where(is_finished: 0).where(arel_table[:ed_at].in(st..ed))
  }

  def is_finished?
    is_finished == 1
  end

  def is_finished_label
    self.class.finished_show(is_finished)
  end

  def self.finished_show(finished)
    finished_select.rassoc(finished).try(:first)
  end

  def self.finished_select
    [['未完了', 0],['完了', 1]]
  end

  def self.gw_schedules_form_todo_st_at_ids
    [['時刻', '0'], ['日付', '1'], ['期限なし', '2']]
  end

  def self.gw_schedules_form_todo_ed_at_ids
    [['日付のみ', '1'], ['日付／時刻', '0'], ['期限なし', '2']]
  end

  def self.gw_schedules_form_todo_repeat_time_ids
    [['日付のみ', '1'], ['日付／時刻', '0']]
  end

  def todo_ed_at_label
    case todo_ed_at_id
    when 0 then ed_at.strftime('%Y-%m-%d %H:%M')
    when 1 then ed_at.strftime('%Y-%m-%d')
    else '期限なし'
    end
  end

  def deadline
    case todo_ed_at_id
    when 0 then ed_at
    when 1 then Time.local(ed_at.year, ed_at.month, ed_at.day, 23, 59, 59)
    else nil
    end
  end

  def over_deadline?(time = Time.now)
    !is_finished? && deadline && time > deadline
  end

  def reminder_date
    case todo_ed_at_id
    when 0 then ed_at
    when 1 then Time.local(ed_at.year, ed_at.month, ed_at.day, 23, 59, 59)
    else Time.local(2030, 4, 1, 23, 59, 59) # 期限なしは最上部に表示
    end
  end

  def reminder_date_str
    case todo_ed_at_id
    when 0 then ed_at.strftime("%m/%d %H:%M")
    when 1 then ed_at.strftime("%m/%d 23:59")
    else '期限なし'
    end
  end
end
