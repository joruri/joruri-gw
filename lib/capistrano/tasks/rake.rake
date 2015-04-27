namespace :db do
  desc 'Migrate database schema'
  task :migrate do
    on primary(fetch(:web_role)) do
      execute "cd #{fetch(:deploy_to)}; bundle exec rake db:migrate RAILS_ENV=#{fetch(:stage)}"
    end
  end
end

namespace :assets do
  desc 'Precompile assets'
  task :precompile do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; bundle exec rake assets:precompile RAILS_ENV=#{fetch(:stage)}"
    end
  end
end

namespace :cache do
  desc 'Clear cache'
  task :clear do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; bundle exec rake cache:clear RAILS_ENV=#{fetch(:stage)}"
    end
  end
end
