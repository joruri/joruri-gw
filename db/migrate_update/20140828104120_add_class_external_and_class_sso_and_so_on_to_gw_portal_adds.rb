class AddClassExternalAndClassSsoAndSoOnToGwPortalAdds < ActiveRecord::Migration
  def change
    add_column :gw_portal_adds, :class_external, :integer, :after => :publish_end_at
    add_column :gw_portal_adds, :class_sso, :integer, :after => :class_external
    add_column :gw_portal_adds, :field_account, :string, :after => :class_sso
    add_column :gw_portal_adds, :field_pass, :string, :after => :field_account
    add_column :gw_portal_adds, :click_count, :integer, :null => false, :default => 0 
    add_column :gw_portal_adds, :is_large, :integer
  end
end
