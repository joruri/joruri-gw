################################################################################
#フォーム情報
################################################################################
class Questionnaire::Admin::Menus::FormFieldsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システム（設問登録）'
    @system_path = "/#{self.system_name}"
    params[:limit] = 100

    @title = Questionnaire::Base.where(:id => params[:parent_id]).first
    return http_error(404) unless @title
    permit_selection
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Core.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Core.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Core.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Core.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return error_auth unless is_creator

    item = Questionnaire::FormField.new
    item.and "sql", %Q((question_type = "group" or group_code IS NULL))
    item.and :parent_id, @title.id
    item.order :sort_no, :id
    item.page params[:page], params[:limit]
    @items = item.find(:all)
    _index @items
  end

  def new
    return error_auth unless is_creator

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
    return error_auth unless is_creator

    @item = Questionnaire::FormField.new(form_field_params)
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
    return error_auth unless is_creator

    @item = Questionnaire::FormField.where(:id => params[:id]).first
  end
  def edit
    return error_auth unless is_creator

    @item = Questionnaire::FormField.where(:id => params[:id]).first
    permit_selection(@item.sort_no)
  end

  def update
    return error_auth unless is_creator

    @item = Questionnaire::FormField.where(:id => params[:id]).first
    return http_error(404) unless @item
    @item.attributes = form_field_params
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
    return error_auth unless is_creator

    @item = Questionnaire::FormField.where(:id => params[:id]).first
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
   @permit_select = Questionnaire::FormField.where(sql.where).order('sort_no, id').collect{ |i| [cut_off(i.title,40), i.id]}
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

private

  def form_field_params
    params.require(:item).permit(:state, :title, :question_type, :group_name, :group_code, :group_repeat, :field_cols, :field_rows,
      :required_entry, :post_permit, :post_permit_value).tap do |whitelisted|
      whitelisted[:_options] = params[:item][:_options].permit! if params[:item][:_options]
    end
  end

end
