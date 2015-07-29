# encoding: utf-8
class Gw::Script::Schedule
  def self.delete
    puts "#{self}.delete"
    dump "#{self}.delete"
    success = 0
    error   = 0

    key = 'schedules'
    options = {}
    options[:class_id] = 3
    settings = Gw::Model::Schedule.get_settings key, options
    return if settings['schedules_admin_delete'].blank?
    x = 6 * settings['schedules_admin_delete'].to_i
    return if x <= 0

    d1 = Date.today
    d1 = d1 << x
    sches = Gw::Schedule.find_by_sql(["select * from gw_schedules where ed_at < :d", {:d => "#{d1.strftime('%Y-%m-%d 0:0:0')}"} ])
    sches.each do |schedule|
      if schedule.delete
        puts "  => success.\n"
        success += 1

        schedule.schedule_users.each do |schedule_user|
          schedule_user.delete
        end

        schedule.schedule_props.each do |schedule_props|
          schedule_props.delete
        end

      else
        puts "  => failed.\n"
        error   += 1
      end
    end

    repeats = Gw::ScheduleRepeat.find_by_sql(["select * from gw_schedule_repeats where ed_date_at < :d", {:d => "#{d1.strftime('%Y-%m-%d 0:0:0')}"} ])
    repeats.each do |repeat|
      repeat.delete
    end

    if success > 0
      ActiveRecord::Base::connection::execute 'optimize table gw_schedules;'
      ActiveRecord::Base::connection::execute 'optimize table gw_schedule_users;'
      ActiveRecord::Base::connection::execute 'optimize table gw_schedule_repeats;'
      ActiveRecord::Base::connection::execute 'optimize table gw_schedule_props;'
      ActiveRecord::Base::connection::execute 'analyze table gw_schedules;'
      ActiveRecord::Base::connection::execute 'analyze table gw_schedule_users;'
      ActiveRecord::Base::connection::execute 'analyze table gw_schedule_repeats;'
      ActiveRecord::Base::connection::execute 'analyze table gw_schedule_props;'
    end

    puts "#{Core.now} - Success:#{success}, Error:#{error}"
    dump "#{Core.now} - Success:#{success}, Error:#{error}"
  end
end
