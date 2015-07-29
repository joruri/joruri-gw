# encoding: utf-8
module System::Controller::Admin::Auth::Login

protected
  def logged_in?
    current_user != false
  end

  def new_login(account, password)
    return false unless user = System::User.authenticate(account, password)
    if user.groups.length != 1
      case user.groups.length
      when 1,2
        flash.discard :notice
      else
        flash[:notice] = '所属設定が異常です。<br />管理者に連絡してください。'
        return false
      end
    end
    session[:user_id]  = user.id
    session[:user_account]  = user.code
    session[:user_password] = user.encrypt_password
    JoruriContext[:current_user] = user
  end

  def new_login_mobile(account, password, mobile_password)
    return false unless user = System::User.authenticate(account, password)
    if user.groups.length != 1
      case user.groups.length
      when 1,2
        flash.discard :notice
      else
        flash[:notice] = '所属設定が異常です。<br />管理者に連絡してください。'
        return false
      end
    end
    if user.mobile_access == 1 && !user.mobile_password.to_s.empty? && user.mobile_password == mobile_password
      session[:user_id]  = user.id
      session[:user_account]  = user.code
      session[:user_password] = user.encrypt_password
      session[:user_mobile_password] = user.mobile_password
      session[:recent_mail] = get_recents(user.code, user.password,user.mobile_password)
      JoruriContext[:current_user] = user
      return true
    else
      return false
    end
  end

  def get_recents(uid,pass,mobile_pass)
    recents = Gw::Controller::Mobile.get_recent_mail(uid,pass,mobile_pass)
    return recents
  end

  def set_current_user(user)
    session[:user_id]  = user.id
    session[:user_account]  = user.code
    session[:user_password] = user.encrypt_password
    session[:user_mobile_password] = user.mobile_password
    session[:recent_mail] = get_recents(user.code, user.password,user.mobile_password)
    JoruriContext[:current_user] = user
    return true
  end

  def current_user

    if ( defined? DEBUG_LOGIN )
        account = "gwbbs"
    password = "gwbbsadmin"
        return false unless account && new_login(account, password)
    end

    return JoruriContext[:current_user] if JoruriContext[:current_user]
    return false if (!session[:user_account] || !session[:user_password])

    if request.mobile?
      unless _user = System::User.authenticate(session[:user_account], session[:user_password], true)
        return false
      end
      if session[:expired_at] && session[:expired_at] < Time.now
        reset_session
        return false
      end
      session[:expired_at] = Time.now + 1.hours

    else
      unless _user = System::User.authenticate(session[:user_account], session[:user_password], true)
        return false
      end
    end

    JoruriContext[:current_user] = _user
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
  HTTP_AUTH_HEADERS = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  def get_auth_data
    auth_key  = HTTP_AUTH_HEADERS.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
  end
end
