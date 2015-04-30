namespace :passenger do
  desc 'Restart passenger'
  task :restart do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        execute :touch, "tmp/restart.txt"
      end
    end
  end
end
