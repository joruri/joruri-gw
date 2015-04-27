#####################################################################################
#
#####################################################################################
module Questionnaire::Model::Database

  def system_admin_flags
    #システムで登録されている管理者(システム管理者)ならtrueを返す
    @is_sysadm = Core.user.has_role?('enquete/admin')
    params[:cond] = '' unless @is_sysadm if params[:cond] == 'admin'
  end

end