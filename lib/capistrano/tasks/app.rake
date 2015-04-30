namespace :app do
  desc 'Deploy application'
  task :deploy do
    invoke "git:pull"
    invoke "db:migrate"
  end

  desc 'Restart application'
  task :restart do
    invoke "delayed_job:restart"
    invoke "passenger:restart"
  end
end

namespace :cron do
  desc 'Update cron setting on primary web server'
  task :update do
    on primary(:app) do
      within fetch(:deploy_to) do
        execute :whenever, "-i --set 'environment=#{fetch(:stage)}'"
      end
    end
  end
end

desc 'Execute command'
task :exec do |task|
  unless ENV['command']
    puts "usage: cap #{task.name} command=[COMMAND]"
    next
  end
  on roles(:app), fetch(:run_options) do
    within fetch(:deploy_to) do
      execute ENV['command']
    end
  end
end

desc 'Upload local file to remote web servers'
task :upload do |task|
  unless ENV['file']
    puts "usage: cap #{task.name} file=[FILE]"
    next
  end
  on roles(:app), fetch(:run_options) do
    upload!(ENV['file'], File.join(fetch(:deploy_to), ENV['file']))
  end
end

desc 'Download file from remote servers to local server'
task :download do |task|
  unless ENV['file']
    puts "usage: cap #{task.name} file=[FILE]"
    next
  end
  on roles(:app), fetch(:run_options) do |server|
    download!(File.join(fetch(:deploy_to), ENV['file']), File.join(fetch(:deploy_to), "#{ENV['file']}.#{server.hostname}"))
  end
end
