# -*- encoding: utf-8 -*-
class Digitallibrary::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Digitallibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Digitallibrary::Admin::DocsHelper

  layout "admin/template/digitallibrary"

  #
  def initialize_scaffold
    @title = Digitallibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    Page.title = @title.title
    return redirect_to("/digitallibrary/docs?title_id=#{params[:title_id]}&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    begin
      _search_condition
    rescue
      return http_error(404)
    end
    initialize_value_set_new_css_dl

    is_normal_idx = true
    is_normal_idx = false if params[:state].to_s == 'DATE'
    if is_normal_idx
      @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]
    else
      @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_1column_dl.css"]
    end
  end

  def _search_condition
    params[:cat] = 1 if params[:cat].blank?
    item = digitallib_db_alias(Digitallibrary::Folder)
    @parent = item.find_by_id(params[:cat])
    Digitallibrary::Folder.remove_connection
    @groups = Gwboard::Group.level3_all_hash
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    state = 'public'
    state = 'draft' if params[:state] == 'DRAFT'
    case params[:state].to_s
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      search_index(state)  unless params[:kwd].blank?
      normal_index(state) if params[:kwd].blank?
    end
    Digitallibrary::Doc.remove_connection
    Digitallibrary::Folder.remove_connection
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(@title.id)

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    item = digitallib_db_alias(Digitallibrary::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    Digitallibrary::Doc.remove_connection
    return http_error(404) unless @item
    return http_error(404) if @item.state == 'preparation'
    Page.title = @item.title
    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)
    @is_readable = true if @is_recognize_readable
    @is_editable = Digitallibrary::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)
    return authentication_error(403) unless @is_readable

    if @item.state == 'draft' && !@is_editable
      return http_error(404)
    end

    Page.title = @item.title

    @item.doc_alias = 0 if @item.doc_alias.blank?

    item = digitallib_db_alias(Digitallibrary::File)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, @item.id if @item.doc_alias.to_i == 0
    item.and :parent_id, @item.doc_alias unless @item.doc_alias.to_i == 0
    item.order  'id'
    @files = item.find(:all)

    case params[:state].to_s
    when 'RECOGNIZE'
      recognize_index(true)
    when 'PUBLISH'
      recognized_index(true)
    else
      normal_pp_index
    end

    get_recogusers

    @is_publish = true if @is_admin if @item.state == 'recognized'
    @is_publish = true if @item.section_code.to_s == Site.user_group.code.to_s if @item.state == 'recognized'

    Digitallibrary::File.remove_connection
  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    item = digitallib_db_alias(Digitallibrary::Doc)
    @item = item.create({
      :state => 'preparation',
      :latest_updated_at => Time.now,
      :parent_id  => @parent.id ,
      :chg_parent_id => @parent.id ,
      :title_id  => params[:title_id] ,
      :doc_alias  => 0,
      :doc_type  => 1,
      :level_no => @parent.level_no + 1,
      :seq_no => 999999999.0,
      :order_no => 999999999 ,
      :sort_no => 1999999999 ,
      :display_order => 100,
      :section_code => Site.user_group.code,
      :category4_id => 0,
      :category1_id => params[:cat]
    })

    @item.state = 'draft'

    seq_name_update(@parent.id)

    set_parent_docs_hash
    set_tree_list_hash('new')
    set_position_hash(1)
    users_collection unless @title.recognize == 0
    Digitallibrary::Doc.remove_connection
    Digitallibrary::Folder.remove_connection
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = digitallib_db_alias(Digitallibrary::Doc)
    ditem = item.new
    ditem.and :id, params[:id]
    @item = ditem.find(:first)
    return http_error(404) unless @item

    get_role_edit(@item)
    @is_editable = Digitallibrary::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)
    return authentication_error(403) unless @is_editable

    @item.section_code = Site.user_group.code if @item.section_code.blank?

    set_parent_docs_hash
    set_tree_list_hash('edit')
    set_position_hash(1)

    @item.category4_id = 0 if @item.category4_id.blank?
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end

    @item.doc_alias = 0 if @item.doc_alias.blank?
    unless @item.doc_alias == 0
      ditem = item.new
      ditem.and :id, @item.doc_alias
      @parent_item = ditem.find(:first)

      item = digitallib_db_alias(Digitallibrary::File)
      item = item.new
      item.and :title_id, params[:title_id]
      item.and :parent_id, @item.id if @item.doc_alias.to_i == 0
      item.and :parent_id, @item.doc_alias unless @item.doc_alias.to_i == 0
      item.order  'id'
      @files = item.find(:all)
    end
    Digitallibrary::Doc.remove_connection
    Digitallibrary::File.remove_connection
    Digitallibrary::Folder.remove_connection
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    unless @title.recognize.to_s == '0'
      users_collection
    end

    item = digitallib_db_alias(Digitallibrary::Doc)
    @item = item.find(params[:id])
    return http_error(404) unless @item

    set_parent_docs_hash
    set_tree_list_hash('update')
    set_position_hash(1)

    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now
    @item.doc_type = 1
    @item.section_code = Site.user_group.code if @item.section_code.blank?
    @item.section_name  = @item.section_code.to_s + @item.get_section_name(@item.section_code).to_s

    update_creater_editor
    @item._doc_update = true
    @item.save

    flg_sno = true
    unless @item.parent_id == @item.chg_parent_id
      old_p_id = @item.chg_parent_id
      new_p_id = @item.parent_id
      @item.parent_id = @item.chg_parent_id
      @item.seq_no = 999999999.0
      @item.save
      item = digitallib_db_alias(Digitallibrary::Folder)
      level_no_rewrite(@item, item)
      seq_name_update(old_p_id)
      seq_name_update(new_p_id)
      flg_sno = false
    end

    unless @item.order_no == @item.seq_no
      @item.parent_id == @item.chg_parent_id
      @item.save
      seq_name_update(@item.parent_id)
      flg_sno = false
    end
    @item.doc_alias = 0 if @item.doc_alias.blank?
    update_alias_docs if @item.doc_alias.to_i == 0
    set_alias_data unless @item.doc_alias.to_i == 0

    seq_name_update(@item.parent_id) if flg_sno

    Digitallibrary::Folder.remove_connection

    group = Gwboard::Group.new
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item._note_section = group.name if group
    @item._bbs_title_name = @title.title
    @item._notification = @title.notification

    next_location = "#{digitallibrary_docs_path({:title_id=>@title.id})}&state=#{params[:state]}#{digitallib_uri_params}"
    if @title.recognize == 0
      _update_plus_location(@item, next_location,:digitallibrary=>true)
    else
      _update_after_save_recognizers(@item, digitallib_db_alias(Digitallibrary::Recognizer), next_location,:digitallibrary=>true)
    end

  end

  def destroy
    item = digitallib_db_alias(Digitallibrary::Doc)
    @item = item.find(params[:id])
    return http_error(404) unless @item

    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    destroy_atacched_files
    destroy_files
    @item._notification = @title.notification
    @item.destroy

    seq_name_update(@item.parent.id)
    Digitallibrary::Doc.remove_connection
    str_param = ''
    str_param += "&cat=#{params[:cat]}" unless params[:cat].blank?
    redirect_to "#{digitallibrary_docs_path(:title_id=>@title.id)}#{str_param}"
  end

  def normal_index(state)
    unless params[:state] == 'DATE'
      item = digitallib_db_alias(Digitallibrary::Folder)
      folder = item.find_by_id(params[:cat])
      params[:cat] = 1 if folder.blank?
      level_no = 2 if folder.blank?
      parent_id = 1 if folder.blank?

      level_no = folder.level_no + 1 unless folder.blank?
      parent_id = folder.id unless folder.blank?

      item = digitallib_db_alias(Digitallibrary::Folder)
      item = item.new
      param_state = 'public'
      param_state = 'closed' if state == 'draft'
      item.and :state, param_state
      item.and :doc_type, 0
      item.and :title_id, params[:title_id]
      if state == 'draft'
        unless @is_admin
          item.and "sql", "(creater_id = '#{Site.user.code}' or section_code = '#{Site.user_group.code}')"
        end
      else
        item.and :level_no, level_no
        item.and :parent_id, parent_id
      end
      item.page   params[:page], params[:limit]
      @folders = item.find(:all, :order=>"level_no, sort_no, id")
    end

    item = digitallib_db_alias(Digitallibrary::Doc)
    item = item.new
    item.and :state, state
    item.and :doc_type, 1 if params[:state] == 'DATE'
    item.and :title_id, params[:title_id]
    if state == 'draft' && !@is_admin
      item.and "sql", "(creater_id = '#{Site.user.code}' or section_code = '#{Site.user_group.code}')"
    end
    item.and :parent_id, parent_id if state == 'public' unless params[:state] == 'DATE'
    item.page   params[:page], params[:limit]
    str_order = "level_no, display_order , sort_no, id"
    str_order = "latest_updated_at DESC, level_no, sort_no, id" if params[:state] == 'DATE'
    @items = item.find(:all, :order=> str_order)
  end

  def normal_pp_index
    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and 'sql', "parent_id IS NULL"
    @items = item.find(:all, :order=>"level_no, sort_no, id")
    @fip = 0
    @fip_hash = Hash::new
    @fip_hash.store(@fip, 0)  #[seq, id]
    set_next_and_prev_page(@items)


    hash_fip = @fip_hash.invert #hash　[id, seq]
    current = hash_fip[params[:id].to_i]
    current = current.to_i

    prev_page = current - 1
    prev_page = nil if prev_page < 1
    unless prev_page.blank?
      @previous = @fip_hash[prev_page]
    else
      @previous = nil
    end

    next_page = current + 1
    next_page = nil if @fip_hash.length < next_page
    unless next_page.blank?
      @next = @fip_hash[next_page]
    else
      @next = nil
    end
  end

  def set_next_and_prev_page(items)
    return false if items.blank?
    state = 'public'
    state = 'draft' if params[:state] == 'DRAFT'
    items.each do |item|
      if item.doc_type == 1
        @fip += 1
        @fip_hash.store(@fip, item.id)
      end
      sub_folders = item.children.select{|x| x.state == state}
      set_next_and_prev_page(sub_folders) unless sub_folders.count == 0
    end
  end

  def search_index(state)
    search_item = digitallib_db_alias(Digitallibrary::Folder)
    item = search_item.new
    item.and :state, state
    item.and :title_id, params[:title_id]
    if state == 'draft' && !@is_admin
      item.and "sql", "(creater_id = '#{Site.user.code}' or section_code = '#{Site.user_group.code}')"
    end
    item.search params
    item.page params[:page], params[:limit]

    case params[:state]
    when 'DATE'
      item.order "latest_updated_at DESC, level_no, sort_no, id"
    else
      item.order "level_no, sort_no, id"
    end

    @items = item.find(:all)
  end

  def set_alias_data
    item = digitallib_db_alias(Digitallibrary::Doc)
    item = item.find(@item.doc_alias)
    if item
      @item.state = item.state
      @item.body = item.body
      @item.title = item.title if @item.title.blank?
    end
  end

  def update_alias_docs
    inx = digitallib_db_alias(Digitallibrary::Doc)
    inx = inx.new
    inx.and :doc_alias, @item.id
    items = inx.find(:all)
    items.each do |item|
      item.state = @item.state
      item.body = @item.body
      item.title = @item.title  if item.title.blank?

      item.latest_updated_at = @item.latest_updated_at
      item.editdate = @item.editdate
      item.editor = @item.editor
      item.editordivision = @item.editordivision
      item.editor_id = @item.editor_id
      item.editordivision_id = @item.editordivision_id
      item.editor_admin = @item.editor_admin
      item.editor_admin = @item.editor_admin
      item.save
    end
  end

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_atacched_files
    item = digitallib_db_alias(Digitallibrary::File)
    item.destroy_all(sql_where)
    Digitallibrary::File.remove_connection
  end

  def destroy_files
    item = digitallib_db_alias(Digitallibrary::DbFile)
    item.destroy_all(sql_where)
    Digitallibrary::DbFile.remove_connection
  end

  def recognize_index(no_paginate=nil)
    sql = Condition.new
    sql.or {|d|
      d.and "sql", "digitallibrary_docs.state = 'recognize'"
      d.and "sql", "digitallibrary_docs.doc_type = 1"
      d.and "sql", "digitallibrary_docs.section_code = '#{Site.user_group.code}'" unless @is_admin
    }
    sql.or {|d|
      d.and "sql", "digitallibrary_docs.state = 'recognize'"
      d.and "sql", "digitallibrary_docs.doc_type = 1"
      d.and "sql", "digitallibrary_recognizers.code = '#{Site.user.code}'"
    }
    join = "INNER JOIN digitallibrary_recognizers ON digitallibrary_docs.id = digitallibrary_recognizers.parent_id AND digitallibrary_docs.title_id = digitallibrary_recognizers.title_id"
    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all,:select=>'digitallibrary_docs.*', :joins=>join, :conditions=>sql.where,:order => 'latest_updated_at DESC', :group => 'digitallibrary_docs.id')
  end

  def recognized_index(no_paginate=nil)
    item = digitallib_db_alias(Digitallibrary::Folder)
    item = item.new
    item.and :title_id, @title.id
    item.and :state, 'recognized'
    item.and :doc_type, 1
    item.and :section_code, Site.user_group.code  unless @is_admin
    item.search params
    item.order  "level_no, sort_no, id"
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def publish_update
    item = digitallib_db_alias(Digitallibrary::Doc)
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
    Digitallibrary::Doc.remove_connection
    docs_path = digitallibrary_doc_path(item,{:title_id=>@title.id})
    if item.parent_id.blank?
      docs_path += "&cat=#{item.id.to_s}"
    else
      docs_path += "&cat=#{item.parent_id.to_s}"
    end
    redirect_to(docs_path)
  end

  def recognize_update
    item = digitallib_db_alias(Digitallibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:first)
    if item
      item.recognized_at = Time.now
      item.save
    end

    item = digitallib_db_alias(Digitallibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and "sql", "recognized_at IS NULL"
    item = item.find(:all)

    if item.length == 0
      item = digitallib_db_alias(Digitallibrary::Doc)
      item = item.find(params[:id])
      item.state = 'recognized'
      item.recognized_at = Time.now
      item.save

      user = System::User.find_by_code(item.editor_id.to_s)
      unless user.blank?
        show_doc_path = digitallibrary_doc_path(item,{:title_id=>@title.id})
        if item.parent_id.blank?
          show_doc_path += "&cat=#{item.id.to_s}"
        else
          show_doc_path += "&cat=#{item.parent_id.to_s}"
        end
        Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{show_doc_path}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
      end
    end
    Digitallibrary::Recognizer.remove_connection
    get_role_new
    redirect_to("#{@title.docs_path}") unless @is_writable
    redirect_to("#{@title.docs_path}&state=RECOGNIZE") if @is_writable
  end

  def check_recognize
    item = digitallib_db_alias(Digitallibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item.and 'sql', "recognized_at is null"
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Digitallibrary::Recognizer.remove_connection
    return ret
  end

  def check_recognize_readable
    item =  digitallib_db_alias(Digitallibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Digitallibrary::Recognizer.remove_connection
    return ret
  end

  def get_recogusers
    item = digitallib_db_alias(Digitallibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.order 'id'
    @recogusers = item.find(:all)
    Digitallibrary::Recognizer.remove_connection
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end


  def edit_file_memo
    get_role_index
    return authentication_error(403) unless @is_readable

    item = digitallib_db_alias(Digitallibrary::Doc)
    item = item.new
    item.and :id, params[:parent_id]
    @item = item.find(:first)
    Digitallibrary::Doc.remove_connection
    return http_error(404) unless @item
    get_role_show(@item)

    item = digitallib_db_alias(Digitallibrary::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)

    item = digitallib_db_alias(Digitallibrary::File)
    item = item.new
    @file = item.find(params[:id])
    Digitallibrary::File.remove_connection
  end
end
