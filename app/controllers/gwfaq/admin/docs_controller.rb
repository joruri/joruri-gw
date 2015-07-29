# -*- encoding: utf-8 -*-
class Gwfaq::Admin::DocsController < Gw::Controller::Admin::Base

  layout "admin/template/gwfaq"


  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwfaq::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @title = Gwfaq::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    Page.title = @title.title

    params[:state] = "CATEGORY" if params[:state].blank? && @title.category == 1

    return redirect_to(gwfaq_docs_path({:title_id=>@title.id}) + "&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    begin
      _search_condition
    rescue
      return http_error(404)
    end

    initialize_value_set_new_css

  end

  def _search_condition
    item = gwfaq_db_alias(Gwfaq::Category)
    item = item.new
    item.and :title_id, params[:title_id]
    @categories1 = item.find(:all, :order =>'sort_no, id')
    @d_categories = item.find(:all,:select=>'id, name', :order =>'sort_no, id').index_by(&:id)
    Gwfaq::Category.remove_connection
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      normal_index
    end

    Gwfaq::Doc.remove_connection
  end

  def normal_index(no_paginate=nil)
    if params[:state]=='CATEGORY'

      item = gwfaq_db_alias(Gwfaq::Doc)
      item = item.new
      item.and 'gwfaq_docs.title_id' , params[:title_id]
      item.and "sql", gwfaq_select_status(params)
      item.order gwboard_sort_key(params,'gwfaq')
      item.search params
      item.page(params[:page], params[:limit])  if no_paginate.blank?
      @items = item.find(:all,:select=>'gwfaq_docs.*', :joins => ['inner join gwfaq_categories on gwfaq_categories.id = gwfaq_docs.category1_id'])
    else

      item = gwfaq_db_alias(Gwfaq::Doc)
      item = item.new
      item.and 'gwfaq_docs.title_id' , params[:title_id]
      item.and "sql", gwfaq_select_status(params)
      item.order gwboard_sort_key(params,'gwfaq')
      item.search params
      item.page(params[:page], params[:limit])  if no_paginate.blank?
      @items = item.find(:all)
    end
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(params[:title_id])

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item

    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)  #admin, readable, editable
    @is_readable = true if @is_recognize_readable
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'RECOGNIZE'
      recognize_index(true)
    when 'PUBLISH'
      recognized_index(true)
    else
      normal_index(true)
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

    @next_page = current + 1
    @next_page = nil if @items.length < @next_page
    unless @next_page.blank?
      @next = @items[@next_page - 1]
    else
      @next = nil
    end

    item = gwfaq_db_alias(Gwfaq::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)

    get_recogusers
    @is_publish = true if @is_admin if @item.state == 'recognized'
    @is_publish = true if @item.section_code.to_s == Site.user_group.code.to_s if @item.state == 'recognized'
    Page.title = @item.title unless @item.title.blank?

    Gwfaq::File.remove_connection
    Gwfaq::Doc.remove_connection

  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    item = gwfaq_db_alias(Gwfaq::Doc)
    @item = item.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :section_code => Site.user_group.code,
      :category4_id => 0,
      :title => '',
      :body => ''
    })

    @item.state = 'draft'
    users_collection unless @title.recognize == 0
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
    @item.category4_id = 0 if @item.category4_id.blank?
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    unless @title.recognize.to_s == '0'
      users_collection
    end

    item = gwfaq_db_alias(Gwfaq::Doc)
    @item = item.find(params[:id])
    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now
    @item.category_use = @title.category

    update_creater_editor

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
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}"
    when 'draft'
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}&state=DRAFT"
    when 'recognize'
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}&state=RECOGNIZE"
    else
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}#{gwbbs_params_set}"
    end
    if @title.recognize == 0
      _update_plus_location(@item, next_location)
    else
      _update_after_save_recognizers(@item, gwfaq_db_alias(Gwfaq::Recognizer), next_location)
    end
  end

  def destroy
    item = gwfaq_db_alias(Gwfaq::Doc)
    @item = item.find(params[:id])

    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    destroy_atacched_files
    destroy_files

    @item._notification = @title.notification
    _destroy @item, :success_redirect_uri => gwfaq_docs_path({:title_id=>@title.id})
  end

  def sql_where
    sql = Condition.new
    sql.and "parent_id", @item.id
    sql.and "title_id", @item.title_id
    return sql.where
  end

  def destroy_atacched_files
    item = gwfaq_db_alias(Gwfaq::File)
    item.destroy_all(sql_where)

  end

  def destroy_files
    item = gwfaq_db_alias(Gwfaq::DbFile)
    item.destroy_all(sql_where)
  end

  def recognize_index(no_paginate=nil)
    sql = Condition.new
    sql.or {|d|
      d.and "sql", "gwfaq_docs.state = 'recognize'"
      d.and "sql", "gwfaq_docs.section_code = '#{Site.user_group.code}'" unless @is_admin
    }
    sql.or {|d|
      d.and "sql", "gwfaq_docs.state = 'recognize'"
      d.and "sql", "gwfaq_recognizers.code = '#{Site.user.code}'"
    }
    join = "INNER JOIN gwfaq_recognizers ON gwfaq_docs.id = gwfaq_recognizers.parent_id AND gwfaq_docs.title_id = gwfaq_recognizers.title_id"
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all,:select=>'gwfaq_docs.*', :joins=>join, :conditions=>sql.where,:order => 'latest_updated_at DESC', :group => 'gwfaq_docs.id')
  end

  def recognized_index(no_paginate=nil)
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :title_id, @title.id
    item.and "sql", gwfaq_select_status(params)
    item.search params
    item.order gwboard_sort_key(params,'gwfaq')
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def publish_update
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :state, 'recognized'
    item.and :title_id, @title.id
    item.and :id, params[:id]

    item = item.find(:first)
    if item
      item.state = 'public'
      item.published_at = Time.now
      item.save
    end
    Gwfaq::Doc.remove_connection
    redirect_to gwfaq_docs_path({:title_id=>@title.id})
  end

  def recognize_update
    item = gwfaq_db_alias(Gwfaq::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:first)
    if item
      item.recognized_at = Time.now
      item.save
    end

    item = gwfaq_db_alias(Gwfaq::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and "sql", "recognized_at IS NULL"
    item = item.find(:all)

    if item.length == 0
      item = gwfaq_db_alias(Gwfaq::Doc)
      item = item.find(params[:id])
      item.state = 'recognized'
      item.recognized_at = Time.now
      item.save
      user = System::User.find_by_code(item.editor_id.to_s)
      unless user.blank?
        Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{gwfaq_doc_path(item,{:title_id=>@title.id})}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
      end
    end
    Gwfaq::Recognizer.remove_connection
    get_role_new
    redirect_to("#{gwfaq_docs_path({:title_id=>@title.id})}") unless @is_writable
    redirect_to("#{gwfaq_docs_path({:title_id=>@title.id})}&state=RECOGNIZE") if @is_writable
  end

  def check_recognize
    item = gwfaq_db_alias(Gwfaq::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item.and 'sql', "recognized_at is null"
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Gwfaq::Recognizer.remove_connection
    return ret
  end

  def check_recognize_readable
    item = gwfaq_db_alias(Gwfaq::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Gwfaq::Recognizer.remove_connection
    return ret
  end

  def get_recogusers
    item = gwfaq_db_alias(Gwfaq::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.order 'id'
    @recogusers = item.find(:all)
    Gwfaq::Recognizer.remove_connection
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end

private
  def invalidtoken
    return authentication_error(403)
  end
end
