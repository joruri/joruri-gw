require 'time'
class System::Admin::LdapTemporariesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @role_admin = @admin = System::User.is_admin?
    return error_auth unless @admin

    Page.title = "LDAP同期"
  end

  def index
    case params[:do]
    when 'preview'
      return _preview
    when 'create'
      return _create
    end

    @items = System::LdapTemporary.group(:version).order(version: :desc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @groups = System::LdapTemporary.where(:version => params[:id], :parent_id => 0, :data_type => 'group').order(:code)

    case params[:do]
    when 'synchro'
      return _synchro
    end
  end

  def destroy
    System::LdapTemporary.where(:version => params[:id]).delete_all

    message = "中間データを削除しました［ version: #{params[:id]} ］"
    redirect_to url_for(:action => 'index'), :notice => message
  end

private

  def _preview
    notice = if Core.ldap.connection.bound?
      "LDAPサーバに接続可能です。"
    else
      "LDAPサーバに接続できません。"
    end
    redirect_to url_for(:action => :index), :notice => notice
  end

  def _create
    @version = (Time.now - Time.parse("1970-01-01T00:00:00Z")).to_i
    @results = System::LdapTemporary.create_temporary(@version)

    flash[:notice] = "中間データを作成しました［ version: #{@version} ］"
    redirect_to :action => :show, :id => @version
  end

  def _synchro
    @version = params[:id]
    @errors = System::LdapTemporary.synchronize(@version)

    if @errors.size > 0
      flash[:notice] = 'Error: <br />' + @errors.join('<br />')
    else
      flash[:notice] = '同期処理が完了しました'
    end
    redirect_to url_for(:action => :show)
  end
end
