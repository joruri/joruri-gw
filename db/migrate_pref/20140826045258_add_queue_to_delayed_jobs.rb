class AddQueueToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :queue, :string, after: :locked_by
  end
end
