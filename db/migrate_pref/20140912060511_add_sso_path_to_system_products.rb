class AddSsoPathToSystemProducts < ActiveRecord::Migration
  def change
    add_column :system_products, :sort_no, :integer, :default => 0
    add_column :system_products, :product_synchro, :integer, :limit => 1, :default => 0
    add_column :system_products, :sso, :integer, :limit => 1, :default => 0
    add_column :system_products, :sso_url, :text
    add_column :system_products, :sso_url_mobile, :text
  end
end
