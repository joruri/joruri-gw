namespace :db do
  desc 'Migrate database schema'
  task :migrate do
    on primary(:app) do
      within fetch(:deploy_to) do
        with rails_env: fetch(:stage) do
          execute :rake, "db:migrate"
        end
      end
    end
  end
end

namespace :assets do
  desc 'Precompile assets'
  task :precompile do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        with rails_env: fetch(:stage) do
          execute :rake, "assets:precompile"
        end
      end
    end
  end
end

namespace :cache do
  desc 'Clear cache'
  task :clear do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        with rails_env: fetch(:stage) do
          execute :rake, "cache:clear"
        end
      end
    end
  end
end
