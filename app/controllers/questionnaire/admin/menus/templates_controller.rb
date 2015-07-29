# -*- encoding: utf-8 -*-
################################################################################
#
################################################################################
class Questionnaire::Admin::Menus::TemplatesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'テンプレート選択'
    Page.title = @system_title
    @system_path = "/#{self.system_name}"

    @title = Questionnaire::Base.find_by_id(params[:parent_id])
    return http_error(404) unless @title
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
    #return authentication_error(403) unless is_creator

    item = Questionnaire::TemplateBase.new
    item.and :state ,'public'
    item.and "sql", "admin_setting = 1 OR (admin_setting = 0 AND createrdivision_id = '#{Site.user_group.code}')"
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'expiry_date DESC, id DESC')
    _index @items
  end

  #既存の設問を削除後選択されたテンプレートをコピーする
  def apply_template
    #return authentication_error(403) unless is_creator

    @title.form_body = nil
    @title.save

    Questionnaire::FormField.destroy_all("parent_id=#{@title.id}")

    item = Questionnaire::TemplateFormField.new
    item.and :state, 'public'
    item.and :parent_id, params[:id]
    item.order 'sort_no, id'
    items = item.find(:all)
    for fld in items
      field = Questionnaire::FormField.create({
        :unid => fld.unid ,
        :content_id => fld.id ,  #テンプレートのレコードid
        :state => fld.state ,
        :created_at => fld.created_at ,
        :updated_at => fld.updated_at ,
        :parent_id => @title.id ,
        :sort_no => fld.sort_no ,
        :question_type => fld.question_type ,
        :title => fld.title ,
        :field_cols => fld.field_cols ,
        :field_rows => fld.field_rows ,
        :post_permit_base => fld.post_permit_base ,
        :post_permit => fld.post_permit ,
        :post_permit_value => fld.post_permit_value ,
        :option_body => fld.option_body ,
        :field_name => fld.field_name ,
        :view_type => fld.view_type ,
        :required_entry => fld.required_entry ,
        :_skip_logic => true,
        :auto_number_state => fld.auto_number_state ,
        :auto_number => fld.auto_number,
        :group_code => fld.group_code ,
        :group_field => fld.group_field ,
        :group_body => fld.group_body ,
        :group_repeat => fld.group_repeat
      })

      unless field.post_permit.blank?
        #入力許可設定の参照先のレコードidが変わっているので調整する
        pitem = Questionnaire::FormField.new
        pitem.and :content_id, field.post_permit
        pitem.and :parent_id , @title.id
        pitem = pitem.find(:first)
        unless pitem.blank?
          field.post_permit = pitem.id
          field._skip_logic = true
          field.save
        end
      end

      add_option_records(fld, field.id)

    end unless items.blank?

    #複製された内容から設問を構築更新
    item = Questionnaire::FormField.new
    item.and :state, 'public'
    item.and :parent_id, @title.id
    item = item.find(:first)
    item.create_form_fields unless item.blank?

    redirect_to questionnaire_menu_form_fields_path(@title)
  end
  #
  def add_option_records(template_id, field_id)
    item = Questionnaire::TemplateFieldOption.new
    item.and :field_id, template_id
    item.order 'sort_no, id'
    items = item.find(:all)
    for option in items
      Questionnaire::FieldOption.create({
        :unid => option.unid ,
        :content_id => option.content_id ,
        :state => option.state ,
        :created_at => option.created_at ,
        :updated_at => option.updated_at ,
        :published_at => option.published_at ,
        :field_id => field_id ,
        :sort_no => option.sort_no ,
        :value => option.value ,
        :title => option.title
      })
    end unless items.blank?
  end

  def new_base
    system_admin_flags
    #return authentication_error(403) unless @is_sysadm

    @item = Questionnaire::TemplateBase.new({
      :state => 'public',
      :section_code => Site.user_group.code ,
      :send_change => '1',  #配信先は所属
      :spec_config => 3 ,   #他の回答者名を表示する
      :manage_title => '',
      :title => @title.title,
      :able_date => Time.now.strftime("%Y-%m-%d"),
      #:expiry_date => 7.days.since.strftime("%Y-%m-%d %H:00"),
      :default_limit => 100,
      :admin_setting => 1
    })
  end

  def create_base
    system_admin_flags
    #return authentication_error(403) unless @is_sysadm

    @item = Questionnaire::TemplateBase.new(params[:item])

    @item.able_date = Time.now.strftime("%Y-%m-%d")
    @item.section_code = Site.user_group.code
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code
    @item.creater = Site.user.name
    @item.createrdivision = Site.user_group.name
    @item.createrdivision_id = Site.user_group.code

    if @is_sysadm
    else
      @item.admin_setting = 0
    end

    if @item.save
      location = "/questionnaire/#{params[:parent_id]}/templates/#{@item.id}/copy_form_fields"
      return redirect_to location
    else
      return render :action => :new_base
    end
  end


  def copy_form_fields

    location = "/questionnaire/templates"
    #return redirect_to location if base_item.blank?
    @template_title = Questionnaire::TemplateBase.find_by_id(params[:id])
    @template_title.form_body = nil
    #@template_title.state = "public"
    @template_title.save

    #Questionnaire::FormField.destroy_all("parent_id=#{@title.id}")
    item = Questionnaire::FormField.new
    item.and :state, 'public'
    item.and :parent_id, params[:parent_id]
    item.order 'sort_no, id'
    items = item.find(:all)
    for fld in items
      field = Questionnaire::TemplateFormField.create({
        :unid => fld.unid ,
        :content_id => fld.id ,  #テンプレートのレコードid
        :state => fld.state ,
        :created_at => fld.created_at ,
        :updated_at => fld.updated_at ,
        :parent_id => @template_title.id ,
        :sort_no => fld.sort_no ,
        :question_type => fld.question_type ,
        :title => fld.title ,
        :field_cols => fld.field_cols ,
        :field_rows => fld.field_rows ,
        :post_permit_base => fld.post_permit_base ,
        :post_permit => fld.post_permit ,
        :post_permit_value => fld.post_permit_value ,
        :option_body => fld.option_body ,
        :field_name => fld.field_name ,
        :view_type => fld.view_type ,
        :required_entry => fld.required_entry ,
        :_skip_logic => true,
        :auto_number_state => fld.auto_number_state ,
        :auto_number => fld.auto_number,
        :group_code => fld.group_code ,
        :group_field => fld.group_field ,
        :group_body => fld.group_body ,
        :group_repeat => fld.group_repeat
      })

      unless field.post_permit.blank?
        #入力許可設定の参照先のレコードidが変わっているので調整する
        pitem = Questionnaire::TemplateFormField.new
        pitem.and :content_id, field.post_permit
        pitem.and :parent_id , @template_title.id
        pitem = pitem.find(:first)
        unless pitem.blank?
          field.post_permit = pitem.id
          field._skip_logic = true
          field.save
        end
      end

      add_template_option_records(fld, field.id)

    end unless items.blank?

    #複製された内容から設問を構築更新
    item = Questionnaire::TemplateFormField.new
    item.and :state, 'public'
    item.and :parent_id, @template_title.id
    item = item.find(:first)
    item.create_form_fields unless item.blank?

    location = "/questionnaire/templates/#{params[:id]}/form_fields"
    return redirect_to location
  end

  def add_template_option_records(parent_id, field_id)
    item = Questionnaire::FieldOption.new
    item.and :field_id, parent_id
    item.order 'sort_no, id'
    items = item.find(:all)
    return if items.blank?
    for option in items
      Questionnaire::TemplateFieldOption.create({
        :unid => option.unid ,
        :content_id => option.content_id ,
        :state => option.state ,
        :created_at => option.created_at ,
        :updated_at => option.updated_at ,
        :published_at => option.published_at ,
        :field_id => field_id ,
        :sort_no => option.sort_no ,
        :value => option.value ,
        :title => option.title
      })
    end unless items.blank?
  end
end
