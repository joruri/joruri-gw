# encoding:utf-8
class Gw::Admin::MemoSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/memo"

  def initialize_scaffold
    Page.title = "連絡メモ設定"
    @css = %w(/_common/themes/gw/css/memo.css)
  end

  def memo_settings_path
    gw_memo_settings_path
  end

  def index
    @is_gw_admin = true
    return

    options={}
    options[:uid] = Site.user.id
    @is_gw_admin = Gw.is_admin_admin?(options)
  end

  def forwarding
    key = 'mobiles'
    @item = Gw::Model::Schedule.get_settings key
    @ktrans = @item['ktrans'].to_i
    @kmail = @item['kmail'].to_s
  end

  def update_forwarding

		#メール送信「する」で、アドレス欄が空ならば設定画面再表示
		if params[:ktrans].to_i == 1 && (params[:kmail].nil? or params[:kmail].to_s.blank?)
			flash[:notice] = "携帯メール転送する場合はメールアドレスを設定してください"
			redirect_to :action => "forwarding"
			return
		end

    key = 'mobiles'
    hu = nz(Gw::Model::UserProperty.get(key.singularize), {})
    default = Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")

    hu[key] = {} if hu[key].nil?
    hu_update = hu[key]
    hu_update['ktrans']   = params[:ktrans]
    hu_update['kmail'] = params[:kmail]
	
    options = {}
    ret = Gw::Model::UserProperty.save(key.singularize, hu, options)
    if ret >= 0
      flash_notice('携帯等メール転送設定', true)
       redirect_to memo_settings_path
    else
      respond_to do |format|
        format.html {
          hu_update['errors'] = ret
          hu_update.merge!(default){|k, self_val, other_val| self_val}
          @item = hu[key]
          render :action => "forwarding"
        }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def reminder
    key = 'memos'
    @item = Gw::Model::Schedule.get_settings key
  end

  def edit_reminder
    key = 'memos'
    _params = params[:item]
    hu = nz(Gw::Model::UserProperty.get(key.singularize), {})
    default = Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")

    hu[key] = {} if hu[key].nil?
    hu_update = hu[key]
    hu_update['read_memos_display']   = _params['read_memos_display']
    hu_update['unread_memos_display'] = _params['unread_memos_display']

    options = {}
    ret = Gw::Model::UserProperty.save(key.singularize, hu, options)
    if ret == true
      flash_notice('表示設定編集処理', true)
       redirect_to memo_settings_path
    else
      respond_to do |format|
        format.html {
          hu_update['errors'] = ret
          hu_update.merge!(default){|k, self_val, other_val| self_val}
          @item = hu[key]
          render :action => "reminder"
        }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def admin_deletes
    check_gw_system_admin
    return http_error(403) unless @is_sysadm
    
    key = 'memos'
    options = {}
    options[:class_id] = 3
    @item = Gw::Model::Schedule.get_settings key, options
  end

  def edit_admin_deletes
    check_gw_system_admin
    return http_error(403) unless @is_sysadm
    
    key = 'memos'
    options = {}
    options[:class_id] = 3

    _params = params[:item]
    hu = nz(Gw::Model::UserProperty.get(key.singularize), {})
    default = Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")

    hu[key] = {} if hu[key].nil?
    hu_update = hu[key]
    hu_update['read_memos_admin_delete']   = _params['read_memos_admin_delete']
    hu_update['unread_memos_admin_delete']   = _params['unread_memos_admin_delete']

    ret = Gw::Model::UserProperty.save(key.singularize, hu, options)
    if ret == true
      flash_notice('連絡メモ削除設定処理', true)
      redirect_to config_url(:config_settings_sakujo)
    else
      respond_to do |format|
        format.html {
          hu_update['errors'] = ret
          hu_update.merge!(default){|k, self_val, other_val| self_val}
          @item = hu[key]
          render :action => "admin_deletes"
        }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

protected
  
  def check_gw_system_admin
    @is_sysadm = System::Model::Role.get(1, Site.user.id ,'_admin', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id ,'_admin', 'admin')
  end

end
