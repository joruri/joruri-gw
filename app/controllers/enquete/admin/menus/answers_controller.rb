# -*- encoding: utf-8 -*-
################################################################################
#フォーム情報
################################################################################
class Enquete::Admin::Menus::AnswersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム'
    Page.title = @system_title
    @title = Questionnaire::Base.find_by_id(params[:title_id])
    return http_error(404) unless @title
    @field_lists = ''
    @field_lists = JsonParser.new.parse(@title.form_body_json) unless @title.form_body.size == 0 unless @title.form_body.blank?

  end

  def index
    redirect_to '/enquete/'
  end

  def new
    return http_error(404) unless @title.state == 'public'
    system_admin_flags
    #非公開
    if @title.include_index == false
      return http_error(404) if params[:k].blank?
      return http_error(404) unless params[:k].to_s == @title.keycode
    end unless @is_sysadm

    #一番最初の回答があったときに設問編集を不可にするため値を設定する
    if @title.answer_count.blank?
      @title.answer_count = 0
      @title.save
    end

    item = Enquete::Answer.new
    item.and :title_id, @title.id
    item.and :user_code, Site.user.code
    item = item.find(:first)
    unless item.blank?
      return redirect_to edit_enquete_answer_path(@title,item) if item.state == 'public'
      Enquete::Answer.destroy_all("title_id=#{@title.id} AND state IS NULL AND user_code='#{Site.user.code}'")
    end

    @item = Enquete::Answer.new({
      :title_id => @title.id,
      :enquete_division => @title.enquete_division,
      :user_code => Site.user.code
    })

  end

  def create
    @item = Enquete::Answer.new(params[:item])

    @item.title_id = @title.id
    @item.user_code = Site.user.code
    @item.enquete_division = @title.enquete_division

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    _self_create @item
  end

  def show
    system_admin_flags

    @item = Enquete::Answer.find_by_id(params[:id])
    return http_error(404) unless @item
    user_check(true)
      _show @item
  end

  def edit
    system_admin_flags

    @item = Enquete::Answer.find_by_id(params[:id])
    return http_error(404) unless @item
    user_check
  end

  def update
    @item = Enquete::Answer.find_by_id(params[:id])
    return http_error(404) unless @item
    user_check

    @item.attributes = params[:item]

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    location = enquete_answer_path(@title, @item)
    _update(@item, :success_redirect_uri=>location)
  end

  def user_check(is_show=nil)
    params[:cond] = 'already' unless @item.state.blank?
    return http_error(404) unless @item.title_id == @title.id
    return http_error(404) unless @item.user_code == Site.user.code
    return redirect_to enquete_answer_path(@title, @item) if @item.base.state == 'closed' unless is_show
  end

  def public_seal
    @item = Enquete::Answer.find_by_id(params[:id])
    return http_error(404) unless @item
    user_check

    @item.attributes = params[:item]

    @item.state = 'public'

    @item.user_name = Site.user.name
    @item.l2_section_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    @item.section_code = Site.user_group.code
    @item.section_name = Site.user_group.name
    @item.section_sort = Site.user_group.sort_no

    @item.createdate = @title.createdate
    @item.creater_id = @title.creater_id
    @item.creater = @title.creater
    @item.createrdivision = @title.createrdivision
    @item.createrdivision_id = @title.createrdivision_id

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code
    @item.editor = Site.user.name
    @item.editordivision = Site.user_group.name
    @item.editordivision_id = Site.user_group.code

    @item.enquete_division = @title.enquete_division
    @item.able_date = @title.able_date
    @item.expiry_date = @title.expiry_date
    @item.latest_updated_at = Time.now

    @item.save
    redirect_to '/enquete/?cond=already'
  end


  def _self_create(item, options = {})
    respond_to do |format|
      validate_option = options[:validation] || true
      validation = {:validate => validate_option}
      if item.creatable? && item.save(validation)
        options[:after_process].call if options[:after_process]
        #system_log.add(:item => item, :action => 'create')
        location = enquete_answer_path(item.title_id, item)
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
