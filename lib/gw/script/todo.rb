# encoding: utf-8
class Gw::Script::Todo
  def self.delete
    puts "#{self}.delete"
    dump "#{self}.delete"
    success = 0
    error   = 0

    key = 'todos'
    options = {}
    options[:class_id] = 3
    settings = Gw::Model::Schedule.get_settings key, options
    return if settings['todos_admin_delete'].blank?
    x = 6 * settings['todos_admin_delete'].to_i
    return if x <= 0

    d1 = Date.today
    d1 = d1 << x
    todos = Gw::Todo.find_by_sql(["select * from gw_todos where is_finished and ed_at < :d", {:d => "#{d1.strftime('%Y-%m-%d 0:0:0')}"} ])
    todos.each do |todo|
      if todo.delete
        puts "  => success.\n"
        success += 1
      else
        puts "  => failed.\n"
        error   += 1
      end
    end

    if success > 0
      ActiveRecord::Base::connection::execute 'optimize table gw_todos;'
      ActiveRecord::Base::connection::execute 'analyze table gw_todos;'
    end

    puts "#{Core.now} - Success:#{success}, Error:#{error}"
    dump "#{Core.now} - Success:#{success}, Error:#{error}"
  end

end
