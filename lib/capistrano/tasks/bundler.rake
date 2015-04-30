namespace :bundle do
  desc 'Install gems'
  task :install do
    on roles(:app) do
      within fetch(:deploy_to) do
        execute :bundle, "install --path vendor/bundle"
      end
    end
  end
end
