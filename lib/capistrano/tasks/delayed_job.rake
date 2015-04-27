namespace :delayed_job do
  [:start, :stop, :restart].each do |operation|
    desc "#{operation.capitalize} delayed_job"
    task operation do
      on roles(fetch(:web_role)), fetch(:run_options) do
        execute "cd #{fetch(:deploy_to)}; bin/delayed_job #{operation} RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end
end
