class AddTmpIdToGwMemos < ActiveRecord::Migration
  def change
    add_column :gw_memos, :tmp_id, :string
  end
end
