class Sys::Admin::AirController < ApplicationController
  include Sys::Controller::Admin::Auth
  layout false

  protect_from_forgery :except => [:old_login, :login]

  def old_login
    render(:text => "NG")
  end

  def login
    @admin_uri = '/gw/portal'

    if params[:account] && params[:password]
      return air_token(params[:account], params[:password], params[:mobile_password])
    elsif params[:account] && params[:token]
      return air_login(params[:account], params[:token])
    end
    render(:text => "NG")
  end

  def air_token(account, password, mobile_password)
    if user = System::User.authenticate(account, password)
      if mobile_password && !user.authenticate_mobile_password(mobile_password)
        user = nil
      end
    end

    return render(:text => 'NG') unless user

    now   = Time.now
    token = Digest::MD5.hexdigest(now.to_f.to_s)
    enc_password = Base64.encode64(Util::Crypt.encrypt(password))

    user_tmp = System::User.find(user.id)
    user_tmp.air_login_id = "#{token} #{enc_password}"
    user_tmp.save(:validate => false)

    render :text => "OK #{token}"
  end

  def air_login(account, token)
    cond = Condition.new do |c|
      c.and :code, account
      c.and :air_login_id, 'IS NOT', nil
      c.and :air_login_id, 'LIKE', "#{token} %"
    end
    user = System::User.where(cond.where).first
    return render(:text => "ログインに失敗しました。") unless user

    token, enc_password = user.air_login_id.split(/ /)

    user.air_login_id = nil
    user.save(:validate => false)

    user.password = Util::Crypt.decrypt(Base64.decode64(enc_password))

    set_current_user(user)

    redirect_to @admin_uri
  end
end
