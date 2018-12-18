class AddWikiToGwmonitorControls < ActiveRecord::Migration
  def change
    add_column :gwmonitor_controls, :wiki, :integer
    Gwmonitor::Control.update_all(:wiki => 0)
  end
end
