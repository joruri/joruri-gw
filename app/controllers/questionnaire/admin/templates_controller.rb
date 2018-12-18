################################################################################
#テンプレート基本情報登録
################################################################################
class Questionnaire::Admin::TemplatesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::TemplateSystemname
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート　テンプレート'
    @system_path = "/questionnaire/templates"
    params[:cond] = "template"
  end

  def index
    system_admin_flags

    if @is_sysadm
      index_admin
    else
      index_normal
    end
    _index @items
  end

  def index_admin
    item = Questionnaire::TemplateBase.new
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'expiry_date DESC, id DESC')
  end

  def index_normal
    item = Questionnaire::TemplateBase.new
    item.and :state ,'public'
    item.and "sql", "admin_setting = 1 OR (admin_setting = 0 AND createrdivision_id = '#{Core.user_group.code}')"
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'updated_at DESC, id ASC')
  end
  def new
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.new({
      :state => 'draft',
      :section_code => Core.user_group.code ,
      :send_change => '1',  #配信先は所属
      :spec_config => 3 ,   #他の回答者名を表示する
      :manage_title => '',
      :title => '',
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => 7.days.since.strftime("%Y-%m-%d %H:00"),
      :default_limit => 100,
      :admin_setting => 1
    })
  end

  def create
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.new(base_params)

    @item.able_date = Time.now.strftime("%Y-%m-%d")
    @item.section_code = Core.user_group.code
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code
    @item.creater = Core.user.name
    @item.createrdivision = Core.user_group.name
    @item.createrdivision_id = Core.user_group.code
    if @is_sysadm
    else
      @item.admin_setting = 0
    end

    _self_create(@item)
  end

  def show
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_show_flg
    return error_auth unless @item_show_flg

    item = Questionnaire::FormField.new
    item.and :parent_id, @item.id
    item.page params[:page], params[:limit]
    @fields = item.find(:all)
    _show @item
  end

  def edit
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_edit_flg
    return error_auth unless @item_edit_flg
  end

  #
  def update
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_edit_flg
    return error_auth unless @item_edit_flg


    @before_state = @item.state

    @item.attributes = base_params

    @item.state = 'closed' if @before_state == 'closed'
    @item._commission_state = @before_state
    @item.section_code = Core.user_group.code
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code
    @item.editor = Core.user.name
    @item.editordivision = Core.user_group.name
    @item.editordivision_id = Core.user_group.code
    if @is_sysadm
    else
      @item.admin_setting = 0
    end

    _update(@item, :success_redirect_uri=>url_for(:action => :index))
  end
  #
  def destroy
    system_admin_flags
    #return error_auth unless @is_sysadm

    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_edit_flg
    return error_auth unless @item_edit_flg

    _destroy(@item, :success_redirect_uri=>url_for(:action => :index))
  end

  def _self_create(item, options = {})
    respond_to do |format|
      validate_option = options[:validation] || true
      validation = {:validate => validate_option}
      if item.creatable? && item.save(validation)
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')
        location = questionnaire_template_path(item)
        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _item_show_flg
    if @is_sysadm || @item.admin_setting == 1 || (@item.admin_setting == 0 && @item.createrdivision_id == Core.user_group.code)
      @item_show_flg = true
    end
  end
  def _item_edit_flg
    if @is_sysadm || (@item.admin_setting == 0 && @item.createrdivision_id == Core.user_group.code)
      @item_edit_flg = true
    end
  end

  def open
    system_admin_flags
    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_edit_flg
    return error_auth unless @item_edit_flg

    @item.state = "public"
    @item.save(:validate=>false)
    location = "/questionnaire/templates/#{params[:id]}"
    flash[:notice] = '公開処理が完了しました。'
    return redirect_to location
  end
  def close
    system_admin_flags
    @item = Questionnaire::TemplateBase.where(:id => params[:id]).first
    return http_error(404) unless @item
    _item_edit_flg
    return error_auth unless @item_edit_flg

    @item.state = "draft"
    @item.save(:validate=>false)
    location = "/questionnaire/templates/#{params[:id]}"
    flash[:notice] = '公開取り消し処理が完了しました。'
    return redirect_to location
  end

private

  def base_params
    params.require(:item).permit(:manage_title, :title, :admin_setting, :state)
  end

end
