class System::Admin::LdapGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
		@role_admin = @admin = System::User.is_admin?
    return error_auth unless @admin

    if params[:parent] == '0'
      @parent  = nil
      @parents = []
    else
      @parent  = Core.ldap.group.find(params[:parent])
      @parents = @parent.parents
    end

    Page.title = "LDAP同期"
  end
  
  def index
    if !@parent
      @groups = Core.ldap.group.children
      @users  = []
    else
      @groups = @parent.children
      @users  = @parent.users
    end
  end
end
