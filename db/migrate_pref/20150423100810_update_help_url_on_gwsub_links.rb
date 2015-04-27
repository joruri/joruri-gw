class UpdateHelpUrlOnGwsubLinks < ActiveRecord::Migration
  def change
    production_url = Joruri.config.application['migrate.production_url']
    execute "UPDATE adminlibrary_controls SET help_url = concat('#{production_url}',help_url);"
    execute "UPDATE adminlibrary_controls SET help_admin_url =  concat('#{production_url}',help_admin_url);"
    execute "UPDATE gwsub_sb10_proposal_mailinglist_helps SET bbs_url = concat('#{production_url}',bbs_url) where bbs_url NOT LIKE '%#{production_url}%' ;"
    execute "UPDATE gwsub_sb10_proposal_userid_helps SET bbs_url = concat('#{production_url}',bbs_url) where bbs_url NOT LIKE '%#{production_url}%' ;"
    execute "UPDATE gwsub_sb10_proposal_license_helps SET bbs_url = concat('#{production_url}',bbs_url) where bbs_url NOT LIKE '%#{production_url}%' ;"
    execute "UPDATE gwsub_sb10_proposal_software_helps SET bbs_url = concat('#{production_url}',bbs_url) where bbs_url NOT LIKE '%#{production_url}%' ;"
  end
end
