namespace :passenger do
  desc 'Restart passenger'
  task :restart do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; touch tmp/restart.txt"
    end
  end
end
