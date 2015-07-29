# -*- encoding: utf-8 -*-
################################################################################
#フォーム情報
################################################################################
class Questionnaire::Admin::Menus::FormFieldsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname

  layout "admin/template/portal_1column"
  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム（設問登録）'
    Page.title = @system_title
    @system_path = "/#{self.system_name}"
    params[:limit] = 100

    @title = Questionnaire::Base.find_by_id(params[:parent_id])
    return http_error(404) unless @title
    permit_selection
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Site.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Site.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return authentication_error(403) unless is_creator

    item = Questionnaire::FormField.new
    item.and :parent_id, @title.id
    item.order :sort_no, :id
    item.page params[:page], params[:limit]
    @items = item.find(:all)
    _index @items
  end

  def new
    return authentication_error(403) unless is_creator

    options = []
    for i in 0..9
      options << Questionnaire::FieldOption.new
    end

    item = Questionnaire::FormField.new
    item.and :parent_id, @title.id
    items = item.find(:all)
    sort_no = (items.size + 1) * 10
    @item = Questionnaire::FormField.new({
      :state => 'public',
      :sort_no => sort_no,
      :title => '【問−　】',
      :field_cols => 60,
      :field_rows => 3,
      :options => options,
      :group_repeat => 3
    })
  end

  def create
    return authentication_error(403) unless is_creator

    @item = Questionnaire::FormField.new(params[:item])
    if params[:n_sort_no].blank?
      @item.sort_no = params[:g_sort_no]
    else
      @item.sort_no = params[:n_sort_no]
    end
    @item.parent_id = @title.id
    return render :action => :new if params[:command] && params[:command]['addrow']
    @item.auto_number_state = false
    location = questionnaire_menu_form_fields_path(@title)
    _create(@item, :success_redirect_uri=>location)
  end

  def show
    return authentication_error(403) unless is_creator

    @item = Questionnaire::FormField.find_by_id(params[:id])
  end
  def edit
    return authentication_error(403) unless is_creator

    @item = Questionnaire::FormField.find_by_id(params[:id])
    permit_selection(@item.sort_no)
  end

  def update
    return authentication_error(403) unless is_creator

    @item = Questionnaire::FormField.find_by_id(params[:id])
    return http_error(404) unless @item
    @item.attributes = params[:item]
    if params[:n_sort_no].blank?
      @item.sort_no = params[:g_sort_no]
    else
      @item.sort_no = params[:n_sort_no]
    end
    permit_selection(@item.sort_no)

    return render :action => :edit if params[:command] && params[:command]['addrow']


    @item.parent_id = @title.id
    @item.auto_number_state = false
    location = questionnaire_menu_form_fields_path(@title)
    _update(@item, :success_redirect_uri=>location)
  end

  def destroy
    return authentication_error(403) unless is_creator

    @item = Questionnaire::FormField.find_by_id(params[:id])
    location = questionnaire_menu_form_fields_path(@title)
    _destroy(@item, :success_redirect_uri=>location)
  end

  def permit_selection(sort_no=nil)
    sql = Condition.new
    sql.or {|d|
      d.and :parent_id, @title.id
      d.and :state, 'public'
      d.and :question_type, 'radio'
      d.and :sort_no, '<=', sort_no unless sort_no.blank?
      d.and :id, '!=', params[:id] unless params[:id].blank?
    }
    sql.or {|d|
      d.and :parent_id, @title.id
      d.and :state, 'public'
      d.and :question_type, 'checkbox'
      d.and :sort_no, '<=', sort_no unless sort_no.blank?
      d.and :id, '!=', params[:id] unless params[:id].blank?
    }
    sql.or {|d|
      d.and :parent_id, @title.id
      d.and :state, 'public'
      d.and :question_type, 'select'
      d.and :sort_no, '<=', sort_no unless sort_no.blank?
      d.and :id, '!=', params[:id] unless params[:id].blank?
   }
    item = Questionnaire::FormField.new
    @permit_select = item.find(:all, :conditions=>sql.where, :order=>'sort_no, id').collect{ |i| [cut_off(i.title,40), i.id]}
  end

  def cut_off(text, len)
    if text != nil
      if text.split(//).size < len
        text
      else
        text.scan(/^.{#{len}}/m)[0] + "…"
      end
    else
      ''
    end
  end

end
