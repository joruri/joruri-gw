module Cms::Controller::Admin::Authentication
  include Cms::Controller::Common::Xml
  include Cms::Controller::Admin::Authentication::Login

  def self.included(mod)
    mod.layout 'admin'
    mod.before_filter :initialize_application_admin
    mod.rescue_from ActiveRecord::RecordNotFound, :with => :error_auth
  end

  def initialize_application_admin
    if authenticate
      Site.user  = current_user
      Site.user_group = current_user.groups[0]
    end

    @id = params[:id]
    @do = params[:do]
    @in = params[:in] ? params[:in] : {}
    @sv = params[:s]  ? params[:s]  : {}
    @sv = {:reset => true} if @sv[:reset]
  end

  def authenticate
    return true  if logged_in?
    return false if request.env['PATH_INFO'] =~ /login/
    return respond_to do |format|
      format.html { redirect_to('/_admin/login?url=' + CGI.escape(Site.request_path)) }
      format.xml  { error 'This is a secure page.' }
    end
  end

  def error_auth
    error 'Could not access a page.'
  end
end