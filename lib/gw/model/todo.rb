# encoding: utf-8
module Gw::Model::Todo

  def self.remind(uid = nil)
    item = Gw::Todo.new
    d = Date.today
    setting = Gw::Model::Schedule.get_settings 'todos',{}
    return {} if setting['finish_todos_display'].to_i == 0 && setting['unfinish_todos_display_start'].to_i == 0 && setting['unfinish_todos_display_end'].to_i == 0
    items = item.find(:all, :order => 'ed_at',
      :conditions => remind_cond(d, uid, setting))

    return items.collect{|x|
      delay = nz(Gw.datetimediff(Date.today, x.ed_at, :ignore_time=>1), -1)
      delay_s = delay >= 0 ? "last#{delay}" : 'delay'
      {
        :date_str => x.ed_at.nil? ? '期限なし' : x.ed_at.strftime("%m/%d %H:%M"),
        :cls => 'TODO',
        :title => %Q(<a href="/gw/todos/#{x.id}">#{x._title}</a>),
        :delay => x.ed_at.nil? ? false : Time.now > x.ed_at,
        :css_class => delay_s,
        :date_d => nz(x.ed_at, Time.local(2030, 4, 1, 23, 59, 59))
    }}
  end

  def self.remind_xml(uid , xml_data=nil)
    #dump ["Gw::Tool::Reminder.checker_api　todos_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    return xml_data if uid.blank?
    return xml_data if xml_data.blank?
    item = Gw::Todo.new
    d = Date.today
    setting = Gw::Model::Schedule.get_settings 'todos',{:uid=>"#{uid}"}
    return xml_data if setting['finish_todos_display'].to_i == 0 && setting['unfinish_todos_display_start'].to_i == 0 && setting['unfinish_todos_display_end'].to_i == 0
    items = item.find(:all, :order => 'ed_at',
      :conditions => remind_cond(d, uid, setting))
    if items.blank?
      return xml_data
    end
    items.each do |todo|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{todo.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gw/todos/#{todo.id}"/>)
      if todo.ed_at.blank?
        xml_data  << %Q(<updated>期限なし</updated>)
      else
        xml_data  << %Q(<updated>#{todo.ed_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      end
      xml_data  << %Q(<category term="todo">TODO</category>)
      xml_data  << %Q(<title>#{todo.title}</title>)
      xml_data  << %Q(<author><name></name></author>)
      xml_data  << %Q(</entry>)
    end
    return xml_data
  end

  def self.remind_cond(d, uid = nil, options={})
    ret = "#{Gw::Todo.cond(uid)} and gw_todos.ed_at is not null"
    if options['finish_todos_display'].blank? || options['unfinish_todos_display_start'].blank? || options['unfinish_todos_display_end'].blank?
      return ret
    end
    tmp = ''
    read_d = d - options['finish_todos_display'].to_i + 1
    if !options['finish_todos_display'].blank? && options['finish_todos_display'].to_i != 0
      tmp += " ( gw_todos.is_finished = 1 and ( ( gw_todos.ed_at >= '#{read_d.strftime('%Y-%m-%d 0:0:0')}' and gw_todos.ed_at < '#{d.strftime('%Y-%m-%d 23:59:59')}' ) ) )"
    elsif options['finish_todos_display'].to_i == 0
      tmp += " ( coalesce(gw_todos.is_finished, 0) != 1 ) "
    end

    tie = ''
    if options['finish_todos_display'].to_i == 0
      tie = " and " if tmp != ""
    else
      tie = " or " if tmp != ""
    end
    start_d = d - options['unfinish_todos_display_start'].to_i + 1
    end_d = d + options['unfinish_todos_display_end'].to_i
    if !options['unfinish_todos_display_start'].blank? && options['unfinish_todos_display_start'].to_i != 0 && !options['unfinish_todos_display_end'].blank? && options['unfinish_todos_display_end'].to_i != 0
      tmp += tie
      tmp += " coalesce(gw_todos.is_finished, 0) != 1 and ( ( gw_todos.ed_at >= '#{start_d.strftime('%Y-%m-%d 0:0:0')}'  and gw_todos.ed_at < '#{end_d.strftime('%Y-%m-%d 0:0:0')}' ) ) "
    elsif options['unfinish_todos_display_start'].to_i != 0 && options['unfinish_todos_display_end'].to_i == 0
      tmp += tie
      tmp += " ( coalesce(gw_todos.is_finished, 0) != 1 and ( ( gw_todos.ed_at >= '#{start_d.strftime('%Y-%m-%d 0:0:0')}'  and gw_todos.ed_at < '#{d.strftime('%Y-%m-%d 23:59:59')}' ) ) )"
    elsif options['unfinish_todos_display_start'].to_i == 0 && options['unfinish_todos_display_end'].to_i != 0
      tmp += tie
      tmp += " ( coalesce(gw_todos.is_finished, 0) != 1 and ( ( gw_todos.ed_at >= '#{d.strftime('%Y-%m-%d 0:0:0')}'  and gw_todos.ed_at < '#{end_d.strftime('%Y-%m-%d 0:0:0')}' ) ) )"
    elsif options['unfinish_todos_display_start'].to_i == 0 && options['unfinish_todos_display_end'].to_i == 0
      tmp += " and " if tmp != ""
      tmp += " ( coalesce(gw_todos.is_finished, 0) != 0 ) "
    end

    ret += " and  ( " + tmp + " ) " if (tmp != '')
    "(#{ret})"
  end

end
