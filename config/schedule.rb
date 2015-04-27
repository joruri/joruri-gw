# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

env :PATH, ENV['PATH']
set :output, 'log/cron.log'

every :day, :at => '3:00am' do
  rake 'joruri:gw:delete_expired'
end

every :day, :at => '0:00am' do
  rake 'joruri:gw:pref_exective:state_all_off'
end

every '*/10 8-18 * * *' do
  rake 'joruri:gw:meeting_monitor:notice'
end

every 30.minutes do
  rake 'joruri:gw:schedule_prop:cancel_timeup'
end

every 10.minutes do
  rake 'joruri:system:product_synchro:run'
end
