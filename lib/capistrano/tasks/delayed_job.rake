namespace :delayed_job do
  [:start, :stop, :restart].each do |operation|
    desc "#{operation.capitalize} delayed_job"
    task operation do
      on roles(:job), fetch(:run_options) do
        within fetch(:deploy_to) do
          with rails_env: fetch(:stage) do
            execute "bin/delayed_job", operation
          end
        end
      end
    end
  end
end
