#####################################################################################
#
#####################################################################################
module Questionnaire::Model::Database

  def system_admin_flags
    #システムで登録されている管理者(システム管理者)ならtrueを返す
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,'enquete', 'admin')
    #自分の所属idがシステムで登録されている管理者(システム管理者)ならtrueを返す
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,'enquete', 'admin') unless @is_sysadm
    params[:cond] = '' unless @is_sysadm if params[:cond] == 'admin'
  end

end