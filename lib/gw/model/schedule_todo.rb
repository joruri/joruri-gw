module Gw::Model::Schedule_todo

  def self.remind(user = Core.user)
    property = Gw::Property::TodoSetting.where(uid: user.id).first_or_new
    return {} if property.todos['finish_todos_display'].to_i == 0 && property.todos['unfinish_todos_display_start'].to_i == 0 && property.todos['unfinish_todos_display_end'].to_i == 0

    items = Gw::ScheduleTodo.todos_for_reminder(user, property).preload(:schedule).all
    items.map do |item|
      delay = nz(Gw.datetimediff(Date.today, item.ed_at, :ignore_time=>1), -1)
      delay_s = delay >= 0 ? "last#{delay}" : 'delay'
      {
        :date_str => item.reminder_date_str,
        :cls => 'TODO',
        :title => %Q(<a href="/gw/schedules/#{item.schedule_id}/show_one">#{item.schedule.title}</a>),
        :delay => item.deadline && item.deadline < Time.now,
        :css_class => delay_s,
        :date_d => item.reminder_date
      }
    end
  end

  def self.remind_xml(user, xml_data)
    dump ["Gw::Tool::Reminder.checker_api　reminder_externals_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),user.id]
    return xml_data if user.blank?
    return xml_data if xml_data.blank?

    property = Gw::Property::TodoSetting.where(uid: user.id).first_or_new.todos
    return xml_data if property.todos['finish_todos_display'].to_i == 0 && property.todos['unfinish_todos_display_start'].to_i == 0 && property.todos['unfinish_todos_display_end'].to_i == 0

    items = Gw::ScheduleTodo.todos_for_reminder(user, property).preload(:schedule).all
    return xml_data if items.blank?

    items.each do |item|
      delay = nz(Gw.datetimediff(Date.today, item.ed_at, :ignore_time=>1), -1)
      delay_s = delay >= 0 ? "last#{delay}" : 'delay'

      href_uri = %Q(/gw/schedules/#{item.schedule_id}/show_one)
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{item.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="#{href_uri}"/>)
      xml_data  << %Q(<updated>#{item.reminder_date_str}</updated>)
      xml_data  << %Q(<category term="todo">TODO</category>)
      xml_data  << %Q(<title>#{item.schedule.title}</title>)
      xml_data  << %Q(<author><name></name></author>)
      xml_data  << %Q(</entry>)
    end
    return xml_data
  end
end
