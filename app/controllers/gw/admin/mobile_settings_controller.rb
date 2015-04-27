class Gw::Admin::MobileSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/template/admin'

  def pre_dispatch
    Page.title = '携帯アクセス設定'
  end

  def index
    init_params
    @user = System::User.where(:code => Core.user.code).first
    return http_error(404) if @user.blank?
  end

  def access_edit
    init_params
    @user = System::User.where(:code => Core.user.code).first
    return http_error(404) if @user.blank?
  end

  def access_updates
    init_params
    @user = System::User.where(:code => Core.user.code).first
    return http_error(404) if @user.blank?

    @user.mobile_access = params[:user]['mobile_access'].to_i
    @user.save(:validate => false)

    @mail_user = Sys::User.where(account: Core.user.code).order(:account).first rescue nil
    if @mail_user.blank?
    else
      @mail_user.mobile_access = params[:user]['mobile_access'].to_i
      @mail_user.save(:validate => false)
    end

    flash[:notice] = "携帯アクセス許可設定を更新しました。"
    return redirect_to "#{url_for(:action => :index)}?#{@qs}"
  end

  def password_edit
    init_params
    @user = System::User.where(:code => Core.user.code).first
    return http_error(404) if @user.blank?
  end

  def password_updates
    init_params

    @user = System::User.where(:code => Core.user.code).first
    return http_error(404) if @user.blank?

    @user.mobile_password = params[:user]['mobile_password'].to_s
    ret = @user.mobile_pass_check

    if ret == true
      @user.save(:validate => false)
      # mail sys_users update
      @mail_user = Sys::User.where(account: Core.user.code).order(:account).first rescue nil
      if @mail_user.blank?
      else
        @mail_user.mobile_password = params[:user]['mobile_password'].to_s
        @mail_user.save(:validate => false)
      end

      flash[:notice] = "携帯アクセスパスワードを更新しました。"
      return redirect_to "#{url_for(:action => :index)}?#{@qs}"
    else
      respond_to do |format|
        format.html { render :action => :password_edit }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def init_params
    search_condition
    setting_sortkeys

    @css = %w(/_common/themes/gw/css/gw.css)
  end

  def search_condition
    qsa = ['c1' , 'c2']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'id')
  end

end
