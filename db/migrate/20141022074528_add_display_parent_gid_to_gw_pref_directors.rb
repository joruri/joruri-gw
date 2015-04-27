class AddDisplayParentGidToGwPrefDirectors < ActiveRecord::Migration
  def change
      add_column :gw_pref_directors, :display_parent_gid, :integer
      add_column :gw_pref_directors, :version, :string, :limit => 255
  end
end
