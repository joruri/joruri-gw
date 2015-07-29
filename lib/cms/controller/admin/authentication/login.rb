module Cms::Controller::Admin::Authentication::Login
  @@current_user = false

protected
  def logged_in?
    current_user != false
  end


  def current_user
    return @@current_user if @@current_user
    return false if (!session[:user_account] || !session[:user_password])
    unless _user = System::User.authenticate(session[:user_account], session[:user_password], true)
      return false
    end
    @@current_user = _user
  end

  def authorized?
    true
  end

  def login_required
    username, passwd = get_auth_data
    self.current_user ||= System::User.authenticate(username, passwd) || :false if username && passwd
    logged_in? && authorized? ? true : access_denied
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/account', :action => 'login'
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  def self.included(base)
    #base.send :helper_method, :current_user, :logged_in?
  end

  def login_from_cookie
    return unless cookies[:auth_token] && !logged_in?
    user = System::User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      self.current_user = user
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      flash[:notice] = "Logged in successfully"
    end
  end

private
  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
  end
end
