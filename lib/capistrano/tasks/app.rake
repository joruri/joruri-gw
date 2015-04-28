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
    on primary(fetch(:web_role)) do
      execute "cd #{fetch(:deploy_to)}; whenever -i --set 'environment=#{fetch(:stage)}'"
    end
  end
end

desc 'Execute command'
task :execute do
  unless ENV['command']
    puts "usage: cap #{ARGV.join(' ')} command=[COMMAND]"
    next
  end
  on roles(fetch(:web_role)), fetch(:run_options) do
    execute "cd #{fetch(:deploy_to)}; #{ENV['command']}"
  end
end

desc 'Upload local file to remote web servers'
task :upload do
  unless ENV['file']
    puts "usage: cap #{ARGV.join(' ')} file=[FILE]"
    next
  end
  on roles(fetch(:web_role)), fetch(:run_options) do
    upload!(ENV['file'], File.join(fetch(:deploy_to), ENV['file']))
  end
end

desc 'Download file from remote servers to local server'
task :download do
  unless ENV['file']
    puts "usage: cap #{ARGV.join(' ')} file=[FILE]"
    next
  end
  on roles(fetch(:web_role)), fetch(:run_options) do |server|
    download!(File.join(fetch(:deploy_to), ENV['file']), File.join(fetch(:deploy_to), "#{ENV['file']}.#{server.hostname}"))
  end
end
