# -*- encoding: utf-8 -*-
class Gwbbs::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  layout "admin/template/gwbbs"

  def initialize_scaffold
    @title = Gwbbs::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    return redirect_to("/gwbbs/docs?title_id=#{params[:title_id]}&state=#{params[:state]}") if params[:reset]

    begin
      _category_condition
    rescue
      return http_error(404)
    end

    initialize_value_set_new_css

    params[:state] = @title.default_mode if params[:state].blank?
    Page.title = @title.title
    @css = ["/_common/themes/gw/css/gwbbs_standard.css", "/_common/themes/gw/css/doc_2column.css"]
  end

  def _category_condition
    item = gwbbs_db_alias(Gwbbs::Category)
    item = item.new
    item.and :level_no, 1
    item.and :title_id, params[:title_id]
    @categories1 = item.find(:all,:select=>'id, name', :order =>'sort_no, id')
    @d_categories = item.find(:all,:select=>'id, name', :order =>'sort_no, id').index_by(&:id)
    Gwbbs::Category.remove_connection
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'CATEGORY'
      category_index
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      date_index
    end

    void_item if @is_admin if params[:state].to_s == 'VOID'

    unless params[:kwd].blank?

      item = gwbbs_db_alias(Gwbbs::File)
      item = item.new
      item.and 'gwbbs_files.title_id' , params[:title_id]
      item.and "sql", gwbbs_select_status(params)
      item.search params
      item.page   params[:page], params[:limit]
      @files = item.find(:all,:order=>"filename",:select=>'gwbbs_files.*', :joins => ['inner join gwbbs_docs on gwbbs_files.parent_id = gwbbs_docs.id'])
      Gwbbs::File.remove_connection
    end
    Page.title = @title.title
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(params[:title_id])

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :id, params[:id]
    item.and "sql", gwbbs_select_status(params)
    @item = item.find(:first)
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @item

    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)  #admin, readable, editable
    @is_readable = true if @is_recognize_readable
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'CATEGORY'
      category_index(true)
    when 'RECOGNIZE'
      recognize_index(true)
    when 'PUBLISH'
      recognized_index(true)
    else
      date_index(true)
    end
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @items

    if params[:pp].blank?
      fip = 0
      for item_pp in @items
        fip += 1
        params[:pp] = fip
        break if item_pp.id == params[:id].to_i
      end
    end
    current = params[:pp]
    current = 1 unless current
    current = current.to_i

    @prev_page = current - 1
    @prev_page = nil if @prev_page < 1
    unless @prev_page.blank?
      @previous = @items[@prev_page - 1]
    else
      @previous = nil
    end
    #次
    @next_page = current + 1
    @next_page = nil if @items.length < @next_page
    unless @next_page.blank?
      @next = @items[@next_page - 1]
    else
      @next = nil
    end

    item = gwbbs_db_alias(Gwbbs::Comment)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'created_at'
    @comments = item.find(:all)
    Gwbbs::Comment.remove_connection

    item = gwbbs_db_alias(Gwbbs::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)
    Gwbbs::File.remove_connection

    get_recogusers

    @is_publish = true if @is_admin if @item.state == 'recognized'
    @is_publish = true if @item.section_code.to_s == Core.user_group.code.to_s if @item.state == 'recognized'

    ptitle = ''
    ptitle = @title.notes_field09 unless @title.notes_field09.blank? if @title.form_name == 'form003'
    ptitle = @item.title unless @title.form_name == 'form003'
    Page.title = ptitle unless ptitle.blank?

  end

  def get_recogusers
    item = gwbbs_db_alias(Gwbbs::Recognizer)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.order 'id'
    @recogusers = item.find(:all)
    Gwbbs::Recognizer.remove_connection
  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 3 unless default_published

    item = gwbbs_db_alias(Gwbbs::Doc)
    @item = item.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :title => '',
      :body => '',
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => default_published.months.since.strftime("%Y-%m-%d")
    })

    @item.state = 'draft'
    @item.inpfld_024 = '家族' if @title.form_name == "form003"
    Gwbbs::Doc.remove_connection
    users_collection unless @title.recognize == 0
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @item
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
    @item.category4_id = 0 if @item.category4_id.blank?
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end
    Page.title = @title.title
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    unless @title.recognize.to_s == '0'
      users_collection
    end

    item = gwbbs_db_alias(Gwbbs::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.order 'id'
    @files = item.find(:all)
    Gwbbs::File.remove_connection

    attach = 0
    attach = @files.length unless @files.blank?

    item = gwbbs_db_alias(Gwbbs::Doc)
    @item = item.find(params[:id])
    Gwbbs::Doc.remove_connection

    @before_state = @item.state
    before_able_date = @item.able_date

    @item.attributes = params[:item]

    @item.latest_updated_at = Time.now

    unless @item.expiry_date.blank?
      @item.expiry_date = "#{@item.expiry_date.strftime("%Y-%m-%d")} 23:59:59"  if @item.expiry_date.strftime('%H:%M') == '00:00'
    end
    @item.attachmentfile = attach
    @item.category_use = @title.category
    @item.form_name = @title.form_name

    update_creater_editor   #Gwboard::Controller::Common

    if @item.able_date && @item.able_date > Time.now
      @item.createdate = @item.able_date.strftime("%Y-%m-%d %H:%M")
      @item.creater_id = Core.user.code unless Core.user.code.blank?
      @item.creater = Core.user.name unless Core.user.name.blank?
      @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
      @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?
      @item.editor_id = Core.user.code unless Core.user.code.blank?
      @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      @item.creater_admin = true if @is_admin
      @item.creater_admin = false unless @is_admin
      @item.editor_admin = true if @is_admin          #1
      @item.editor_admin = false unless @is_admin     #0
      @item.editdate = ''
      @item.editor = ''
      @item.editordivision = ''

      @item.latest_updated_at = @item.able_date
    end

    @item.inpfld_006 = Gwboard.fyear_to_namejp_ymd(@item.inpfld_006d) if @title.form_name == "form006"
    @item.inpfld_006 = Gwboard.fyear_to_namejp_ymd(@item.inpfld_006d) if @title.form_name == "form007"
    @item.inpfld_006w = Gwboard.fyear_to_namejp_ym(@item.inpfld_006d) if @title.form_name == "form006"
    @item.inpfld_006w = Gwboard.fyear_to_namejp_ym(@item.inpfld_006d) if @title.form_name == "form007"

    if @title.form_name == "form003"
      str_title = '＊'
      item_03 = Gwboard::Group.new
      item_03.and :code, @item.inpfld_023
      item_03 = item_03.find(:first)
      if @item.inpfld_024 == "家族"
        str_title = "#{@item.inpfld_012} #{@item.inpfld_013} さんの　#{@item.inpfld_014} #{@item.inpfld_015} 様が亡くなられました" if item_03.blank?
        str_title = "#{item_03.name} #{@item.inpfld_012} #{@item.inpfld_013} さんの　#{@item.inpfld_014} #{@item.inpfld_015} 様が亡くなられました" unless item_03.blank?
      else
        str_title = "#{@item.inpfld_012} #{@item.inpfld_025} さんが亡くなられました" if item_03.blank?
        str_title = "#{item_03.name} #{@item.inpfld_012} #{@item.inpfld_025} さんが亡くなられました" unless item_03.blank?
      end
      @item.title = str_title
    end

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item.section_name = group.code + group.name if group
    @item._note_section = group.name if group
    @item._bbs_title_name = @title.title
    @item._notification = @title.notification

    case @item.state
    when 'public'
      next_location = "#{@title.docs_path}"
    when 'draft'
      next_location = "#{@title.docs_path}&state=DRAFT"
    when 'recognize'
      next_location = "#{@title.docs_path}&state=RECOGNIZE"
    else
      next_location = "#{@title.docs_path}#{gwbbs_params_set}"
    end
    if @title.recognize == 0
      _update_plus_location(@item, next_location)
    else
      recog_item = gwbbs_db_alias(Gwbbs::Recognizer)
      Gwbbs::Recognizer.remove_connection
      _update_after_save_recognizers(@item, recog_item, next_location)
    end
  end

  def destroy
    item = gwbbs_db_alias(Gwbbs::Doc)
    @item = item.find(params[:id])
    Gwbbs::Doc.remove_connection
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    destroy_comments
    destroy_atacched_files
    destroy_files

    @item._notification = @title.notification
    _destroy_plus_location(@item, "#{@title.docs_path}#{gwbbs_params_set}" )
  end

  def destroy_void_documents
    admin_flags(@title.id)
    return authentication_error(403) unless @is_admin

    item = gwbbs_db_alias(Gwbbs::Doc)

    doc_item = item.new
    doc_item.and :state, 'preparation'
    doc_item.and :created_at, '<' , Date.yesterday.strftime("%Y-%m-%d") + ' 00:00:00'
    @items = doc_item.find(:all)
    for @item in @items
      destroy_comments
      destroy_atacched_files
      destroy_files
      @item.destroy
    end

    doc_item = item.new
    doc_item.and :state, 'public'
    doc_item.and :expiry_date, '<' , Date.today.strftime("%Y-%m-%d") + ' 00:00:00'
    @items = doc_item.find(:all)
    for @item in @items
      destroy_comments
      destroy_atacched_files
      destroy_files
      @item.destroy
    end
    Gwbbs::Doc.remove_connection
    redirect_to "#{@title.docs_path}#{gwbbs_params_set}"
  end

  def category_index(no_paginate=nil)
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and 'gwbbs_docs.title_id' , params[:title_id]
    item.and "sql", gwbbs_select_status(params)
    item.search(params,@title.form_name)
    item.order gwboard_sort_key_bbs
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all,:select=>'gwbbs_docs.*', :joins => ['inner join gwbbs_categories on gwbbs_categories.id=gwbbs_docs.category1_id'])
    Gwbbs::Doc.remove_connection
  end

  def date_index(no_paginate=nil)
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and 'gwbbs_docs.title_id' , params[:title_id]
    item.and "sql", gwbbs_select_status(params)
    item.search(params,@title.form_name)
    item.order gwboard_sort_key_bbs
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
    Gwbbs::Doc.remove_connection
  end

  def void_item
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and 'gwbbs_docs.title_id' , params[:title_id]
    item.and "sql", gwbbs_select_status(params)
    item.search(params,@title.form_name)
    @void_items = item.find(:all, :select=>'id')
    Gwbbs::Doc.remove_connection
  end

  def recognize_index(no_paginate=nil)
    sql = Condition.new
    sql.or {|d|
      d.and "sql", "gwbbs_docs.state = 'recognize'"
      d.and "sql", "gwbbs_docs.section_code = '#{Core.user_group.code}'" unless @is_admin
    }
    sql.or {|d|
      d.and "sql", "gwbbs_docs.state = 'recognize'"
      d.and "sql", "gwbbs_recognizers.code = '#{Core.user.code}'"
    }
    join = "INNER JOIN gwbbs_recognizers ON gwbbs_docs.id = gwbbs_recognizers.parent_id AND gwbbs_docs.title_id = gwbbs_recognizers.title_id"
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all,:select=>'gwbbs_docs.*', :joins=>join, :conditions=>sql.where,:order => 'latest_updated_at DESC', :group => 'gwbbs_docs.id')
    Gwbbs::Doc.remove_connection
  end

  def recognized_index(no_paginate=nil)
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwbbs_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
    Gwbbs::Doc.remove_connection
  end

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_comments
    item = gwbbs_db_alias(Gwbbs::Comment)
    item.destroy_all(sql_where)
    Gwbbs::Comment.remove_connection
  end

  def destroy_atacched_files
    item = gwbbs_db_alias(Gwbbs::File)
    item.destroy_all(sql_where)
    total = item.sum(:size,:conditions => 'unid = 1')
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = item.sum(:size,:conditions => 'unid = 2')
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save
    Gwbbs::File.remove_connection
  end

  def destroy_files
    item = gwbbs_db_alias(Gwbbs::DbFile)
    item.destroy_all(sql_where)
    Gwbbs::DbFile.remove_connection
  end

  def clone
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_edit(@item)
    clone_doc(@item)
    Gwbbs::Doc.remove_connection
  end

  def edit_file_memo
    get_role_index
    return authentication_error(403) unless @is_readable

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :id, params[:parent_id]
    @item = item.find(:first)
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @item
    get_role_show(@item)

    item = gwbbs_db_alias(Gwbbs::Comment)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'latest_updated_at DESC'
    @comments = item.find(:all)
    Gwbbs::Comment.remove_connection

    item = gwbbs_db_alias(Gwbbs::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)

    item = gwbbs_db_alias(Gwbbs::File)
    item = item.new
    @file = item.find(params[:id])
    Gwbbs::File.remove_connection
  end

  def publish_update
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :state, 'recognized'
    item.and :title_id, params[:title_id]
    item.and :id, params[:id]

    item = item.find(:first)
    if item
      item.state = 'public'
      item.published_at = Time.now
      item.save
    end
    Gwbbs::Doc.remove_connection
    redirect_to(@title.docs_path)
  end

  def recognize_update
    item = gwbbs_db_alias(Gwbbs::Recognizer)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.and :code, Core.user.code
    item = item.find(:first)
    if item
      item.recognized_at = Time.now
      item.save
    end

    item = gwbbs_db_alias(Gwbbs::Recognizer)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.and "sql", "recognized_at IS NULL"
    item = item.find(:all)

    if item.length == 0
      item = gwbbs_db_alias(Gwbbs::Doc)
      item = item.find(params[:id])
      item.state = 'recognized'
      item.recognized_at = Time.now
      item.save

      user = System::User.find_by_code(item.editor_id.to_s)
      unless user.blank?
        Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{item.show_path}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
      end
    end
    Gwbbs::Doc.remove_connection
    Gwbbs::Recognizer.remove_connection
    get_role_new
    redirect_to("#{@title.docs_path}") unless @is_writable
    redirect_to("#{@title.docs_path}&state=RECOGNIZE") if @is_writable
  end

  def check_recognize
    item = gwbbs_db_alias(Gwbbs::Recognizer)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.and :code, Core.user.code
    item.and 'sql', "recognized_at is null"
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Gwbbs::Recognizer.remove_connection
    return ret
  end

  def check_recognize_readable
    item = gwbbs_db_alias(Gwbbs::Recognizer)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:id]
    item.and :code, Core.user.code
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Gwbbs::Recognizer.remove_connection
    return ret
  end

  private
  def invalidtoken
    return http_error(404)
  end

  def gwboard_sort_key_bbs
    ret = ''
    ret = gwboard_sort_key(params,'gwbbs') unless @title.form_name == 'form006'
    ret = gwboard_sort_key_form006 if @title.form_name == 'form006'
    return ret
  end

  def gwboard_sort_key_form006()
    str = ''
    case params[:state]
    when "GROUP"
      str = 'inpfld_002, inpfld_006d DESC, latest_updated_at DESC'
    when "CATEGORY"
      str = 'gwbbs_categories.sort_no ,category1_id, inpfld_006d DESC, latest_updated_at DESC'
    else
      str = 'inpfld_006d DESC, latest_updated_at DESC'
    end
    return str
  end

  def gwboard_sort_key_form007()
    str = ''
    case params[:state]
    when "GROUP"
      str = 'inpfld_002, inpfld_006d DESC, latest_updated_at DESC'
    when "CATEGORY"
      str = 'gwbbs_categories.sort_no ,category1_id, inpfld_006d DESC, latest_updated_at DESC'
    else
      str = 'inpfld_006d DESC, latest_updated_at DESC'
    end
    return str
  end
end
