namespace :bundle do
  desc 'Install gems'
  task :install do
    on roles(fetch(:web_role)) do
      execute "cd #{fetch(:deploy_to)}; bundle install --path vendor/bundle"
    end
  end
end
