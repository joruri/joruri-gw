################################################################################
#フォーム情報
################################################################################
class Questionnaire::Admin::Menus::PreviewsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート管理（プレビュー）'
    @system_path = "/#{self.system_name}"

    @title = Questionnaire::Base.where(:id => params[:parent_id]).first
    return http_error(404) unless @title
    @field_lists = ''
    @field_lists = JSON.parse(@title.form_body) unless @title.form_body.blank?

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

    item = Questionnaire::Preview.new
    item.and :parent_id, @title.id
    item.page params[:page], params[:limit]
    @items = item.find(:all)
    _index @items
  end

  def new
    return error_auth unless is_creator

    Questionnaire::Preview.destroy_all("parent_id=#{@title.id}")

    @item = Questionnaire::Preview.new({
      :state => 'public',
      :parent_id => @title.id
    })
  end

  def create
    return error_auth unless is_creator

    @item = Questionnaire::Preview.new(params[:item])
    @item.parent_id = @title.id

    @item.state = 'public'

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code unless Core.user.code.blank?
    @item.creater = Core.user.name unless Core.user.name.blank?
    @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    location = questionnaire_menu_previews_path(@title)
    _create(@item, :success_redirect_uri=>location)
  end

  def edit
    return error_auth unless is_creator

    @item = Questionnaire::Preview.where(:id => params[:id]).first
    return http_error(404) unless @item
  end

  def update
    return error_auth unless is_creator

    @item = Questionnaire::Preview.where(:id => params[:id]).first
    return http_error(404) unless @item
    @item.attributes = params[:item]

    @item.state = 'public'

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code unless Core.user.code.blank?
    @item.creater = Core.user.name unless Core.user.name.blank?
    @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    location = questionnaire_menu_previews_path(@title)
    _update(@item, :success_redirect_uri=>location)
  end

  def apart_groups
    item = Questionnaire::FormField.new
    item.and :state, 'public'
    item.and :parent_id , @title.id
    item.and :question_type, 'group'
    item.order 'sort_no, id'
    items = item.find(:all)
    for fld in items
      field_name_array =[]
      groups = []
      groups = JSON.parse(fld.group_body) unless fld.group_body.blank?
      field = Hash::new
      group_repeat = fld.group_repeat
      for group in groups
        if group["field_type"]=="radio" or group["field_type"]=="select"
          field_name = "#{fld.field_name}_#{group['field_name']}"
          field_arr = []
          for i in 1 .. group_repeat
            radio_field_name = "#{fld.field_name}_#{i}_#{group['field_name']}"
            if params[radio_field_name].blank?
               field_text = "　"
            else
              option_title = Questionnaire::FieldOption.new
              option_title.and :field_id, group['field_id']
              option_title.and :value, params[radio_field_name][0]
              option_title.order :id
              option_title = option_title.find(:first)
              if option_title.blank?
                field_text = "　"
              else
                field_text = option_title.title
              end
            end
            field_arr << field_text
          end
        else
          field_name = "#{fld.field_name}_#{group['field_name']}"
          field_arr = params[field_name]
        end
        field[field_name] = field_arr
        field_name_array << field_name
      end
      @item[fld.field_name] = JSON.generate(field)
      group_values = ''
      group_values = JSON.parse(@item[fld.field_name]) unless @item[fld.field_name].blank?

      is_all_blank = true
      for fieldname in field_name_array
        for value in group_values[fieldname]
          is_all_blank = false unless value.blank?
        end
      end unless group_values.blank?
      #params[:item]の内容が無い場合,モデル内で全フィールドを初期化するので何かセットしておく
      @item._item_params = "group" if @item._item_params.blank? unless is_all_blank
    end
  end

end
