class ChangeClassSsoAndOtherControllerUseOnGwEditTabsAndSoOn < ActiveRecord::Migration
  def change
    change_column :gw_edit_tabs, :class_sso, :string
    change_column :gw_edit_tabs, :other_controller_use, :string
    change_column :gw_edit_link_pieces, :class_sso, :string
    change_column :gw_portal_adds, :class_sso, :string
  end
end
