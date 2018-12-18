class AddIconFilenameAndIconPositionToGwbbsControls < ActiveRecord::Migration
  def change
    add_column :gwbbs_controls, :icon_filename, :text
    add_column :gwbbs_controls, :icon_position, :string
  end
end
