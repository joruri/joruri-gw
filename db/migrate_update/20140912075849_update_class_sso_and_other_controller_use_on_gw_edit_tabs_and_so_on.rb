class UpdateClassSsoAndOtherControllerUseOnGwEditTabsAndSoOn < ActiveRecord::Migration
  OPTIONS = [['11','mail'],['12','video'],['13','hcs'],['14','plus'],['15','maps']]

  def up
    OPTIONS.each do |no, type|
      execute "update gw_edit_tabs set class_sso = '#{type}' where class_sso = '#{no}'"
      execute "update gw_edit_tabs set other_controller_use = '#{type}' where other_controller_use = '#{no}'"
      execute "update gw_edit_link_pieces set class_sso = '#{type}' where class_sso = '#{no}'"
      execute "update gw_portal_adds set class_sso = '#{type}' where class_sso = '#{no}'"
    end
  end

  def down
     OPTIONS.each do |no, type|
      execute "update gw_edit_tabs set class_sso = '#{no}' where class_sso = '#{type}'"
      execute "update gw_edit_tabs set other_controller_use = '#{no}' where other_controller_use = '#{type}'"
      execute "update gw_edit_link_pieces set class_sso = '#{no}' where class_sso = '#{type}'"
      execute "update gw_portal_adds set class_sso = '#{no}' where class_sso = '#{type}'"
    end
  end
end
