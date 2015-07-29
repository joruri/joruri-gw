# encoding: utf-8
module System::Controller::Public
  include System::Controller::Public::Auth::Login
  include System::Controller::Public::Log
  include System::Controller::Common::Xml

  def self.included(mod)
    mod.before_filter :initialize_application_public
    mod.rescue_from ActiveRecord::RecordNotFound, :with => :error_auth_record_not_found
  end

  def initialize_application_public
    if authenticate
        Core.user  = current_user
        Core.user_group = current_user.groups[0]
      self.class.class_eval { include Gw::Controller::Public }
    end

    @id = params[:id]
    @do = params[:do]
    @in = params[:in] ? params[:in] : {}
    @sv = params[:s]  ? params[:s]  : {}
    @sv = {:reset => true} if @sv[:reset]
  end

  def authenticate
    return true if logged_in?
    return false if request.env['PATH_INFO'] =~ /login/
    return respond_to do |format|
      format.html {
        Core.format = 'html'
        redirect_url = "/login?url=#{CGI.escape(request.env['REQUEST_URI'])}"
        redirect_to(redirect_url)
      }
      format.xml  {
        Core.format = 'xml'
        error 'This is a secure page.'
      }
      format.rss  {
        redirect_to('/error_auth.xml')
        Core.format = 'rss'
        return false
      }
    end
  end

  def error_auth
    error 'Could not access a page.'
  end

  def error_auth_record_not_found
    error 'Could not access a page.<br />ActiveRecord::RecordNotFound.'
  end
end
