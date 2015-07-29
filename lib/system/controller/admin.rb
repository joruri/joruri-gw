# encoding: utf-8
module System::Controller::Admin
  include System::Controller::Admin::Auth::Login
  include System::Controller::Admin::Log
  include System::Controller::Common::Xml

  def self.included(mod)
    mod.layout 'admin'
    mod.before_filter :initialize_application_admin
    mod.rescue_from ActiveRecord::RecordNotFound, :with => :error_auth
  end

  def initialize_application_admin
    if authenticate
      Core.user  = current_user
      Core.user.password = Util::Crypt.decrypt(session[:user_password])
      Core.user_group = current_user.groups[0]
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
      format.html {
        redirect_url = "/_admin/login?url=#{CGI.escape(request.env['REQUEST_URI'])}"
        redirect_to(redirect_url)
      }
      format.xml  { error 'This is a secure page.' }
      format.json  { error 'This is a secure page.' }
    end
  end

  def error_auth(exception)
    logger.warn "error with #{exception}\n  #{exception.backtrace.join("\n  ")}"
    error 'Could not access a page.'
  end
end