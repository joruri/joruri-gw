class Sys::Admin::AccountController < Sys::Controller::Admin::Base
  protect_from_forgery :except => [:login]
  layout false

  before_action :reset_unauthorized_session, only: [:login]

  def login
    admin_uri = '/gw/portal'

    @uri = cookies[:sys_login_referrer] || admin_uri
    @uri = NKF::nkf('-w', @uri)
    unless request.post?
      respond_to do |format|
        format.html { render }
        format.xml  { render(:xml => '<errors />') }
      end
      return
    end

    if Joruri.config.application['sys.refuse_initial_password'] && params[:password].to_s == 'p'+params[:account].to_s
      flash.now[:notice] = "初期パスワードではログインできません。パスワードを変更してください。"
      respond_to do |format|
        format.html {  }
        format.xml  { render(:xml => '<errors />') }
      end
      return true
    end

    if request.mobile?
      login_ok = new_login_mobile(login_params[:account], login_params[:password], login_params[:mobile_password])
    else
      login_ok = new_login(login_params[:account], login_params[:password])
    end

    unless login_ok
      flash.now[:notice] = "ユーザーID・パスワードを正しく入力してください"
      respond_to do |format|
        format.html {  }
        format.xml  { render(:xml => '<errors />') }
      end
      return true
    end

    if params[:remember_me] == "1"
      user = System::User.find(self.current_user.id)
      user.remember_me
      cookies[:auth_token] = {
        :value   => user.remember_token,
        :expires => user.remember_token_expires_at
      }
    end

    cookies.delete :sys_login_referrer

    respond_to do |format|
      format.html { redirect_to_with_session @uri }
      format.xml  { render(:xml => current_user.to_xml) }
    end
  end

  def logout
    if logged_in?
      user = System::User.find(self.current_user.id)
      user.forget_me
    end
    cookies.delete :auth_token
    reset_session
    redirect_to('action' => 'login')
  end

  def info
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => Core.user.to_xml(:root => 'item', :include => :groups) }
    end
  end

  private

  def login_params
    params.permit(:account, :password, :mobile_password)
  end

  def reset_unauthorized_session
    reset_session if params[session_key]
  end

  # jpmobile
  def apply_trans_sid?
    false
  end

  def redirect_to_with_session(url)
    if request.mobile?
      uri = Addressable::URI.parse(url)
      if uri.query_values.present?
        uri.query_values = uri.query_values.merge(session_key.to_sym => jpmobile_session_id)
      else
        uri.query_values = {session_key: jpmobile_session_id}
      end
      redirect_to uri.to_s
    else
      redirect_to url
    end
  end

end