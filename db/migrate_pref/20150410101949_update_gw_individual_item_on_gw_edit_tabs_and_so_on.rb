class UpdateGwIndividualItemOnGwEditTabsAndSoOn < ActiveRecord::Migration
  def change
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/adminlibrary/docs?title_id=1&limit=20';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/pes';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb11/sb11_tec_explanations/view';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind'  where link_url = '/gwsub/sb09/menu';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb10/sb10_proposal_numberids';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb10/sb10_proposal_userids/index_date';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb10/sb10_proposal_mailinglists/index_date';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb10/sb10_proposal_softwares/index_date';"
    execute "UPDATE gw_edit_tabs SET class_sso = 'gw_ind' where link_url = '/gwsub/sb10/sb10_proposal_licenses/';"
    execute "UPDATE gw_edit_link_pieces SET class_sso = 'gw_ind' where link_url = '/gw/maa_schedule_props/show_week?s_genre=facility&amp;cls=bs';"
  end
end
