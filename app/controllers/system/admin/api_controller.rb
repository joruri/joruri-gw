# encoding: utf-8
class System::Admin::ApiController < ApplicationController
  include Sys::Controller::Admin::Auth
  layout 'base'

  def checker
    state,xml = api_checker
    render(:xml=>xml, :state=>state)
  end

  def checker_login
    if request.post?
      state,text = api_checker_login_post(params[:account], params[:password])
      render :text => text
    elsif request.get?
      api_checker_login_get(params[:account], params[:token])
      redirect_to '/'
    end
  end

  def sso_login
    if params[:account] && params[:password]
      return air_token(params[:account], params[:password], params[:mobile_password])
    elsif params[:account] && params[:token]
      return air_login(params[:account], params[:token])
    end
    render(:text => "NG")
  end


protected

  def api_checker
    dump ['api_checker',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]

    if logged_in?
      user = current_user
      # ログイン済のときは、同一アカウントからのリクエストであるかをチェック
      unless params[:account].to_s == user.code.to_s
        unless new_login(params[:account], params[:password])
          xml = Gw::Tool::Reminder.checker_api_error
          return 201,xml
        end
      end
    else
      # 新規ログインでは、アカウント・パスワードをチェック
      unless new_login(params[:account], params[:password])
        xml = Gw::Tool::Reminder.checker_api_error
        return 201,xml
      end
    end
    user = current_user

    dump ['api_checker',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]
    xml = Gw::Tool::Reminder.checker_api(user.id)
    dump ['api_checker_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return 200,xml
  end

  def api_checker_login_post(account, password)
    dump ['api_checker_login_post',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]

    user = System::User.authenticate(account, password)
    return 201,"NG" unless user

    token = Digest::SHA1.hexdigest("#{account}#{password}#{Time.now.to_f.to_s}")
    enc_password = Base64.encode64(Util::Crypt.encrypt(password))

    user.air_token = "#{token} #{enc_password}"
    user.save(:validate=>false)
    dump ['api_checker_login_post',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters,token]
    return 200,"OK #{token}"
  end

  def api_checker_login_get(account, token)
    dump ['api_checker_login_get',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]

    cond = Condition.new
    cond.and :code, account
    cond.and :air_token, 'IS NOT', nil
    cond.and :air_token, 'LIKE', "#{System::User.escape_like(token)} %"
    user = System::User.find(:first, :conditions => cond.where)

    token, enc_password = user.air_token.split(/ /)
    usr_pass = Util::Crypt.decrypt(Base64.decode64(enc_password))

    if user && new_login(account, usr_pass)
      user.air_token = nil
      user.save(:validate=>false)
    end
    dump ['api_checker_login_get',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]
  end

  def air_token(account, password, mobile_password)
    if user = System::User.authenticate(account, password)
      if request.mobile?
        if user.mobile_access == 1 && !user.mobile_password.to_s.blank? && user.mobile_password == mobile_password
        else
          user = nil
        end
      end
    end

    return render(:text => 'NG') unless user

    now   = Time.now
    token = Digest::MD5.hexdigest(now.to_f.to_s)
    enc_password = Base64.encode64(Util::Crypt.encrypt(password))

    user.air_login_id = "#{token} #{enc_password}"
    user.save(:validate => false)
    dump ['air_sso_login_token',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]
    render :text => "OK #{token}"
  end

  def air_login(account, token)
    cond = Condition.new do |c|
      c.and :code, account
      c.and :air_login_id, 'IS NOT', nil
      c.and :air_login_id, 'LIKE', "#{System::User.escape_like(token)} %"
    end
    @user = System::User.find(:first, :conditions => cond.where)
    return render(:text => "ログインに失敗しました。") unless @user

    @token, enc_password = @user.air_login_id.split(/ /)
    if @user
      @user.air_login_id = nil
      @user.save(:validate => false)
    end
    @user.password = Util::Crypt.decrypt(Base64.decode64(enc_password))
    @user.encrypted_password = Util::Crypt.encrypt @user.password
    set_current_user(@user)

    dump ['air_sso_login_token',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters]
    admin_uri = "/"
    admin_uri += "?_jgw_session=#{request.session_options[:id]}" unless request.session_options[:id].blank?
    return redirect_to admin_uri
  end
end