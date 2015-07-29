# -*- encoding: utf-8 -*-
################################################################################
#基本情報登録
#system_admin_flags内部で　adminで無いとき params[:cond] = admin を消去
################################################################################
class Questionnaire::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname


  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム'
    Page.title = @system_title
    @system_path = "/#{self.system_name}"
    params[:limit] = 100
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @item.creater_id == Site.user.code if @is_sysadm
    params[:cond] = 'admin' unless @item.creater_id == Site.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @item.creater_id == Site.user.code  if @item.admin_setting == 0
    ret = true if @item.section_code == Site.user_group.code  if @item.admin_setting == 1
    return ret
  end

  #system_admin_flags内部で　管理者で無いとき params[:cond] = admin を消去
  def index
    system_admin_flags

    case params[:cond]
      when 'admin'
        admin_index
      when 'result'
        result_index
      else
        normal_index
    end
  end
  def admin_index
    return authentication_error(403) unless @is_sysadm

    item = Questionnaire::Base.new
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'expiry_date DESC, id DESC')
  end

  def normal_index
    sql = Condition.new
    #個人宛
    sql.or {|d|
      d.and :admin_setting , 0
      d.and :creater_id, Site.user.code
    }
    #所属宛
    sql.or {|d|
      d.and :admin_setting , 1
      d.and :section_code, Site.user_group.code
    }
    item = Questionnaire::Base.new
    item.page params[:page], params[:limit]
    @items = item.find(:all, :conditions=>sql.where, :order=>'expiry_date DESC, id DESC')
    _index @items
  end

  def result_index
    item = Questionnaire::Base.new
    item.and :state, 'closed'
    item.and :result_open_state, true
    item.and :include_index, true
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order=>'expiry_date DESC, id DESC')
    _index @items
  end

  #設問編集可否で回答なしをチェックしているのでanswer_countはNULLのまま
  def new
    @item = Questionnaire::Base.new({
      :state => 'draft',
      :section_code => Site.user_group.code ,
      :send_change => '1',  #配信先は所属
      :spec_config => 3 ,   #他の回答者名を表示する
      :manage_title => '',
      :title => '',
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => 7.days.since.strftime("%Y-%m-%d %H:00"),
      :default_limit => 100
    })
  end

  def create
    @item = Questionnaire::Base.new(params[:item])

    @item.able_date = Time.now.strftime("%Y-%m-%d")
    @item.section_code = Site.user_group.code
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code
    @item.creater = Site.user.name
    @item.createrdivision = Site.user_group.name
    @item.createrdivision_id = Site.user_group.code
    @item.keycode = generate_key_code
    _self_create(@item)
  end

  def show
    @item = Questionnaire::Base.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator

    item = Questionnaire::FormField.new
    item.and :parent_id, @item.id
    item.page params[:page], params[:limit]
    @fields = item.find(:all)
    _show @item
  end

  def edit
    @item = Questionnaire::Base.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator
  end

  #
  def update
    @item = Questionnaire::Base.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator

    @before_state = @item.state

    @item.attributes = params[:item]

    @item.state = 'closed' if @before_state == 'closed'
    @item._commission_state = @before_state
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    unless @is_sysadm
      @item.section_code = Site.user_group.code
      @item.creater_id = Site.user.code
      @item.creater = Site.user.name
      @item.createrdivision = Site.user_group.name
      @item.createrdivision_id = Site.user_group.code
    end
    @item.keycode = generate_key_code if @item.keycode.blank?
    location = "/questionnaire"
    _update(@item, :success_redirect_uri=>location)
  end
  #
  def destroy
    @item = Questionnaire::Base.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator

    location = "/questionnaire"
    _destroy(@item, :success_redirect_uri=>location)
  end

  def _self_create(item, options = {})
    respond_to do |format|
      validate_option = options[:validation] || true
      validation = {:validate => validate_option}
      if item.creatable? && item.save(validation)
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')
        location = "/questionnaire/#{item.id}"
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

  def open_enq
    open_close_update('public')
  end
  def closed
    open_close_update('closed')
  end

  #
  def open_close_update(state=nil)
    @item = Questionnaire::Base.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator

    @before_state = @item.state

    if state.blank?
      @item.state = 'public'
    else
      @item.state = state
    end

    @item.result_open_state = false
    @item._commission_state = @before_state
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    unless @is_sysadm
      @item.section_code = Site.user_group.code
      @item.creater_id = Site.user.code
      @item.creater = Site.user.name
      @item.createrdivision = Site.user_group.name
      @item.createrdivision_id = Site.user_group.code
    end

    location =  "/questionnaire"
    _update(@item, :success_redirect_uri=>location)
  end

  def generate_key_code
    a = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    code = (
      Array.new(20) do
        a[rand(a.size)]
      end ).join
    return code
  end

end