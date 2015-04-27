namespace :git do
  desc 'Execute git pull'
  task :pull do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; git pull --ff-only"
    end
  end

  desc 'Execute git clone'
  task :clone do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; git clone #{fetch(:repo_url)}"
    end
  end

  desc 'Execute git fetch'
  task :fetch do
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; git fetch"
    end
  end

  desc 'Execute git checkout'
  task :checkout do
    unless ENV['target']
      puts "usage: cap #{ARGV.join(' ')} target=[TAG/BRANCH/FILE]"
      next
    end
    on roles(fetch(:web_role)), fetch(:run_options) do
      execute "cd #{fetch(:deploy_to)}; git checkout #{ENV['target']}"
    end
  end
end
