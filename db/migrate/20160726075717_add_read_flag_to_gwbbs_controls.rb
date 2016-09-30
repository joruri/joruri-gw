class AddReadFlagToGwbbsControls < ActiveRecord::Migration
  def change
    add_column :gwbbs_controls          , :use_read_flag, :boolean, default: false
  end
end
