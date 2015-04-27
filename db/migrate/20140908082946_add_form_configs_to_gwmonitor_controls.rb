class AddFormConfigsToGwmonitorControls < ActiveRecord::Migration
  def change
    add_column :gwmonitor_controls, :form_configs, :text
  end
end
