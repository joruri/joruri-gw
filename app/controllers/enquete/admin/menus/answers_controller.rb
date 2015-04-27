################################################################################
#フォーム情報
################################################################################
class Enquete::Admin::Menus::AnswersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システム'
    @title = Questionnaire::Base.where(:id => params[:title_id]).first
    return http_error(404) unless @title
    @field_lists = ''
    @field_lists = JSON.parse(@title.form_body_json) unless @title.form_body.size == 0 unless @title.form_body.blank?

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

    item = nil
    if @title.send_to == 1
      item = @title.answers.where(section_code: Core.user_group.code).first
      if item && item.user_code != Core.user.code
        flash[:notice] = "「#{@title.title}」は既に「#{item.user_name}」さんが所属として回答済みです。"
        return redirect_to '/enquete/'
      end
    else
      item = @title.answers.where(user_code: Core.user.code).first
    end

    if item
      return redirect_to edit_enquete_answer_path(@title,item) if item.state == 'public'
      @title.answers.where(state: nil, user_code: Core.user.code).destroy_all
    end
    
    @item = Enquete::Answer.new({
      :title_id => @title.id,
      :enquete_division => @title.enquete_division,
      :user_code => Core.user.code
    })
  end

  def create
    @item = Enquete::Answer.new(params[:item])

    @item.title_id = @title.id
    @item.user_code = Core.user.code
    @item.enquete_division = @title.enquete_division

    @item._field_lists = @field_lists
    @item._item_params = params[:item]

    apart_groups

    _self_create @item
  end

  def show
    system_admin_flags

    @item = Enquete::Answer.where(:id => params[:id]).first
    return http_error(404) unless @item
    user_check(true)
      _show @item
  end

  def edit
    system_admin_flags

    @item = Enquete::Answer.where(:id => params[:id]).first
    return http_error(404) unless @item
    user_check
  end

  def update
    @item = Enquete::Answer.where(:id => params[:id]).first
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
    return http_error(404) unless @item.user_code == Core.user.code
    return redirect_to enquete_answer_path(@title, @item) if @item.base.state == 'closed' unless is_show
  end

  def public_seal
    @item = Enquete::Answer.where(:id => params[:id]).first
    return http_error(404) unless @item
    user_check

    #@item.attributes = params[:item]

    @item.state = 'public'

    @item.user_name = Core.user.name
    @item.l2_section_code = Core.user_group.parent.code unless Core.user_group.parent.blank?
    @item.section_code = Core.user_group.code
    @item.section_name = Core.user_group.name
    @item.section_sort = Core.user_group.sort_no

    @item.createdate = @title.createdate
    @item.creater_id = @title.creater_id
    @item.creater = @title.creater
    @item.createrdivision = @title.createrdivision
    @item.createrdivision_id = @title.createrdivision_id

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code
    @item.editor = Core.user.name
    @item.editordivision = Core.user_group.name
    @item.editordivision_id = Core.user_group.code

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
      groups = JSON.parse(fld.group_body_json) unless fld.group_body.blank?
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
