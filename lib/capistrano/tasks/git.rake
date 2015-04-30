namespace :git do
  desc 'Execute git pull'
  task :pull do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        execute :git, "pull --ff-only"
      end
    end
  end

  desc 'Execute git clone'
  task :clone do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        execute :git, "clone #{fetch(:repo_url)}'"
      end
    end
  end

  desc 'Execute git fetch'
  task :fetch do
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        execute :git, "fetch"
      end
    end
  end

  desc 'Execute git checkout'
  task :checkout do |task|
    unless ENV['target']
      puts "usage: cap #{task.name} target=[TAG/BRANCH/FILE]"
      next
    end
    on roles(:app), fetch(:run_options) do
      within fetch(:deploy_to) do
        execute :git, "checkout #{ENV['target']}"
      end
    end
  end
end
