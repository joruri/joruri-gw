class UpdateGwsubLinksOnGwEditTabs < ActiveRecord::Migration
  def up
    execute "update gw_edit_tabs set link_url = '/gwsub/sb05/sb05_requests' where link_url = '/gwsub/sb05/01/sb05_requests'"
    execute "update gw_edit_tabs set link_url = '/gwsub/sb06/sb06_assigned_conferences' where link_url = '/gwsub/sb06/02/sb06_assigned_conferences'"
    execute "update gw_edit_tabs set link_url = '/gwsub/sb06/sb06_budget_notices?v=2' where link_url = '/gwsub/sb06/05/sb06_budget_notices?v=2'"
  end
  def down
  end
end
