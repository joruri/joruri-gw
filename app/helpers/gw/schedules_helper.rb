module Gw::SchedulesHelper


  def get_special_meeting_rooms
    Gw::PropMeetingroom.where(:type_id => 4)
  end


  def prop_remarks(genre)
    class_id = case genre
      when "meetingroom"
        1
      when "rentcar"
        2
      else
        nil
      end
    Gw::PropExtraPmRemark.where(state: 'enabled', prop_class_id: class_id)
  end

  def prop_links
    links = []
    links << {:type_title => "会議室", :genre => "meetingroom",:controller=> :prop_meetingrooms, :action =>:index, :cls=>"pm"}
    links << {:type_title => "レンタカー", :genre => "rentcar",:controller=> :prop_rentcars, :action =>:index, :cls=>"pm"}
    links << {:type_title => "一般施設", :genre => "other",:controller=> :prop_others, :action => :index, :cls => "other"}
  end

    def rentcar_rentable?(ps)
      ![0,1].index(nz(ps,0)).nil?
    end

  def actual_print(value, postfix='')
    "#{value.blank? ? '＿' * 10 : value}#{postfix.to_s}"
  end

  def schedule_to_go(item_to_go)
    I18n.t("enum.common.municipality_code")[item_to_go.to_i]
  end

  def todo_display_link(sp_mode, mode, action)
    if Gw::Property::TodoSetting.todos_display?
      bttodo_class = " on"
    else
      bttodo_class = " off"
    end
    no_display_action = ["show_one", "edit","quote","new","create","update"]
    if @sp_mode == :schedule && mode != 'day' && no_display_action.index(action).blank?
      bttodo = %Q(<div class="btTodo#{bttodo_class}">)
      bttodo += link_to("TODO表示", url_for({:controller=>"/gw/admin/schedule_todos", :action => :edit_user_property_schedule}),
        :onclick => "toggleTodo(); return false;", :id=>"toggleTodoBtn")
      bttodo += %Q(</div>)
      bttodo = bttodo.html_safe
    else
      bttodo = ""
    end
    return bttodo
  end

  def prop_pm_messages_show(genre)
    class_id = Gw::PropExtraPmMessage.genre_to_class_id(genre)
    message = Gw::PropExtraPmMessage.where(state: 1, prop_class_id: class_id).order(sort_no: :asc, updated_at: :desc).first
    return "" if message.blank?

    "<div>#{message.body}</div>".html_safe
  end

  def prop_messages_show(type_id, limit = 1)
    messages = Gw::PropTypesMessage.where(state: 1, type_id: type_id).order(sort_no: :asc, updated_at: :desc).limit(limit).to_a
    return "" if messages.blank?

    "<div>#{messages.map(&:body).join('<br />')}</div>".html_safe
  end

  def search_blank_class(sdt, edt, uid, options = {})
    return false if sdt.blank? || edt.blank?

    schedules = Gw::Schedule.distinct.joins(:schedule_users).with_participant_uids(uid)
      .scheduled_between(sdt, edt).without_todo
      .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)

    schedules.each do |schedule|
      if schedule.allday == 1 || schedule.allday == 2
        return true unless sdt.to_date > schedule.ed_at.to_date || edt.to_date < schedule.st_at.to_date
      else
        return true unless sdt >= schedule.ed_at || edt <= schedule.st_at
      end
    end
    return false
  end

  def show_schedule_edit_icon(d, options={})
    par_a = [%Q(s_date=#{(d).strftime("%Y%m%d")})]
    par_a.push "uid=#{options[:uid]}" if options[:uid].present?
    par_a.push "prop_id=#{options[:prop_id]}" if options[:prop_id].present?
    par_a.push "s_genre=#{options[:s_genre]}" if options[:s_genre].present?
    par_s = Gw.a_to_qs(par_a);
    return %Q(<a href="/gw/schedules/new#{par_s}"><img src="/_common/themes/gw/files/schedule/ic_add.gif" alt="edit" width="15" height="15" align="top" /></a>).html_safe
  end

  def create_month_class(week_add_day, date, holidays, params)
    class_str = %Q(scheduleData #{Gw.weekday_s(week_add_day, :mode => :eh, :no_weekday => 1, :holidays => holidays)})
    class_str.concat ' rangeOut' unless (week_add_day).year == date.year && (week_add_day).month == date.month
    class_str.concat ' today' if (week_add_day) == Date.today
    class_str.concat ' selectDay' if (week_add_day) == nz(params[:s_date], Date.today.to_s).to_date
    return class_str
  end
end
