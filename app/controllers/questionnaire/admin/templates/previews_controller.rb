# -*- encoding: utf-8 -*-
################################################################################
#フォーム情報
################################################################################
class Questionnaire::Admin::Templates::PreviewsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::TemplateSystemname

  layout "admin/template/portal_1column"
  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'テンプレート管理（プレビュー）'
    Page.title = @system_title
    @system_path = "/#{self.system_name}"
    @title = Questionnaire::TemplateBase.find_by_id(params[:parent_id])
    return http_error(404) unless @title
    @field_lists = ''
    @field_lists = JsonParser.new.parse(@title.form_body_json) unless @title.form_body.blank?
    params[:cond] = "template"
  end

  def index
    system_admin_flags

    item = Questionnaire::TemplatePreview.new
    item.and :parent_id, @title.id
    item.page params[:page], params[:limit]
    @items = item.find(:all)
    _index @items
  end

  def new
    system_admin_flags

    Questionnaire::TemplatePreview.destroy_all("parent_id=#{@title.id}")

    @item = Questionnaire::TemplatePreview.new({
      :state => 'public',
      :parent_id => @title.id
    })
  end

  def create
    @item = Questionnaire::TemplatePreview.new(params[:item])
    @item.parent_id = @title.id

    @item.state = 'public'

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code unless Site.user.code.blank?
    @item.creater = Site.user.name unless Site.user.name.blank?
    @item.createrdivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.createrdivision_id = Site.user_group.code unless Site.user_group.code.blank?

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    location = questionnaire_template_previews_path(@title)
    _create(@item, :success_redirect_uri=>location)
  end

  def edit
    system_admin_flags

    @item = Questionnaire::TemplatePreview.find_by_id(params[:id])
    return http_error(404) unless @item
  end

  def update
    @item = Questionnaire::TemplatePreview.find_by_id(params[:id])
    return http_error(404) unless @item
    @item.attributes = params[:item]

    @item.state = 'public'

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code unless Site.user.code.blank?
    @item.creater = Site.user.name unless Site.user.name.blank?
    @item.createrdivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.createrdivision_id = Site.user_group.code unless Site.user_group.code.blank?

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    location = questionnaire_template_previews_path(@title)
    _update(@item, :success_redirect_uri=>location)
  end

  def apart_groups
    item = Questionnaire::TemplateFormField.new
    item.and :state, 'public'
    item.and :parent_id , @title.id
    item.and :question_type, 'group'
    item.order 'sort_no, id'
    items = item.find(:all)
    for fld in items
      field_name_array =[]
      groups = []
      groups = JsonParser.new.parse(fld.group_body_json) unless fld.group_body.blank?
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
              option_title = Questionnaire::TemplateFieldOption.new
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
      @item[fld.field_name] = JsonBuilder.new.build(field)
      group_values = ''
      group_values = JsonParser.new.parse(@item[fld.field_name]) unless @item[fld.field_name].blank?

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
