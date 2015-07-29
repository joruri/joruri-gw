# -*- encoding: utf-8 -*-
class Doclibrary::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Doclibrary::Admin::DocsHelper

  layout "admin/template/doclibrary"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = @title.title
    return redirect_to("#{doclibrary_docs_path}?title_id=#{params[:title_id]}&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    if params[:state].blank?
      params[:state] = 'CATEGORY' unless params[:cat].blank?
      params[:state] = 'GROUP' unless params[:gcd].blank?
      if params[:cat].blank?
        params[:state] = @title.default_folder.to_s if params[:state].blank?
      end if params[:gcd].blank?
    end

    begin
      _search_condition
    rescue
      return http_error(404)
    end
    initialize_value_set
  end

  def _search_condition
    group_hash
    category_hash
    Doclibrary::Doc.remove_connection

    case params[:state]
    when 'CATEGORY'
      params[:cat] = 1 if params[:cat].blank?
      item = doclib_db_alias(Doclibrary::Folder)
      @parent = item.find_by_id(params[:cat])
    else
      if params[:cat].present?
        item = doclib_db_alias(Doclibrary::Folder)
        @parent = item.find_by_id(params[:cat])
      end
    end

    Doclibrary::Folder.remove_connection
    Doclibrary::GroupFolder.remove_connection
  end

  def group_hash
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :title_id , @title.id
    item.and :state, 'public' unless params[:state].to_s == 'DRAFT'
    item.and :state, 'draft' if params[:state].to_s == 'DRAFT'

    items = item.find(:all, :select=>'section_code',:group => 'section_code')
    sql = Condition.new
    if items.blank?
      sql.and :id, 0
    else
      for citem in items
        sql.or :code, citem.section_code
      end
    end
    @select_groups = Gwboard::Group.new.find(:all,:conditions=>sql.where, :select=>'code, name' , :order=>'sort_no, code')
    @groups = Gwboard::Group.level3_all_hash
  end

  def category_hash
    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new
    item.and :state, 'public'
    item.and :title_id , params[:title_id]
    @categories = item.find(:all, :select => 'id, name').index_by(&:id)

    item = doclib_db_alias(Doclibrary::Folder)
    parent = item.find(:all, :conditions=>["parent_id IS NULL"], :order=>"level_no, sort_no, id")
    @select_categories = []
    make_group_trees(parent)
  end

  def make_group_trees(items)
   items.each do |item|
     str = "+"
     str += "-" * (item.level_no - 1)
     @select_categories << [item.id , str + item.name]  if 1 <= item.level_no if item.state == 'public'
     make_group_trees(item.children) if item.children.count > 0
   end if items.count > 0
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable
    if @title.form_name == 'form002'
      index_form002
    else
      index_form001
    end

    Doclibrary::Doc.remove_connection
    Doclibrary::File.remove_connection
    Doclibrary::Folder.remove_connection
    Doclibrary::FolderAcl.remove_connection
    Doclibrary::GroupFolder.remove_connection
  end

  def index_form001
    case params[:state]
    when 'DRAFT'
      category_folder_items('draft') if params[:kwd].blank?
      normal_draft_index
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      category_folder_items if params[:kwd].blank?
      normal_category_index_form001
    end

    search_files_index unless params[:kwd].blank?
  end

  def index_form002
    unless params[:kwd].blank?
      search_index_docs
    else
      if params[:state].to_s== 'DRAFT'
       normal_draft_index_form002
      else
       normal_category_index
      end
    end
  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    item = doclib_db_alias(Doclibrary::Doc)
    str_section_code = Site.user_group.code
    str_section_code = params[:gcd].to_s unless params[:gcd].to_s == '1' unless params[:gcd].blank?
    @item = item.create({
      :state => 'preparation',
      :title_id => @title.id ,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :section_code => str_section_code ,
      :category4_id => 0,
      :category1_id => params[:cat]
    })

    @item.state = 'draft'

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    users_collection unless @title.recognize == 0
  end

  def is_i_have_readable(folder_id)
    return true if @is_recognize_readable
    return false if folder_id.blank?
    p_grp_code = ''
    p_grp_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    grp_code = ''
    grp_code = Site.user_group.code unless Site.user_group.blank?

    sql = Condition.new
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :folder_id, folder_id
      d.and :acl_flag , 0
    }
    if @is_admin

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 9
      }
    else

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 1
        d.and :acl_section_code , p_grp_code
      }

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 1
        d.and :acl_section_code , grp_code
      }

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 2
        d.and :acl_user_code , Site.user.code
      }
    end
    item = doclib_db_alias(Doclibrary::FolderAcl)
    item = item.new
    items = item.find(:all, :conditions => sql.where)
    Doclibrary::FolderAcl.remove_connection
    return false if items.blank?
    return false if items.count == 0
    return true unless items.count == 0
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(params[:title_id])

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    Doclibrary::Doc.remove_connection
    return http_error(404) unless @item
    get_role_show(@item)
    Page.title = @item.title
    return authentication_error(403) unless is_i_have_readable(@item.category1_id)

    unless @is_admin
      if @item.state=='draft'
        if @item.section_code != Site.user_group.code
          return http_error(404)
        end
      end
    end

    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)
    @is_readable = true if @is_recognize_readable
    return authentication_error(403) unless @is_readable

    if @title.form_name == 'form002'
      item = doclib_db_alias(Doclibrary::Folder)
      @parent = item.find_by_id(@item.category1_id)
      Doclibrary::Folder.remove_connection
    end

    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, @item.id unless @title.form_name == 'form002'
    item.and :parent_id, @item.category2_id if @title.form_name == 'form002'
    item.order  'id'
    @files = item.find(:all)
    Doclibrary::File.remove_connection

    get_recogusers
    @is_publish = true if @is_admin if @item.state == 'recognized'
    @is_publish = true if @item.section_code.to_s == Site.user_group.code.to_s if @item.state == 'recognized'
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :id, params[:id]
    @item = item.find(:first)
    Doclibrary::Doc.remove_connection
    return http_error(404) unless @item

    return authentication_error(403) unless is_i_have_readable(@item.category1_id)

    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable

    item = doclib_db_alias(Doclibrary::Doc)
    @item = item.find(params[:id])
    return http_error(404) unless @item

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    unless @title.recognize.to_s == '0'
      users_collection
    end

    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.order 'id'
    @files = item.find(:all)
    Doclibrary::File.remove_connection
    attach = 0
    attach = @files.length unless @files.blank?

    item = doclib_db_alias(Doclibrary::Doc)
    @item = item.find(params[:id])
    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now
    @item.attachmentfile = attach
    @item.category_use = 1
    @item.form_name = @title.form_name

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item.section_name = group.code + group.name if group
    @item._note_section = group.name if group

    update_creater_editor

    if @title.form_name == 'form002'
      set_form002_params
      @item.note = return_form002_attached_url
    end
    section_folder_state_update

    if @title.notification == 1
      note = doclib_db_alias(Doclibrary::FolderAcl)
      note = note.new
      note.and :title_id,  @title.id
      note.and :folder_id, @item.category1_id
      note.and :acl_flag, '<', 9
      notes = note.find(:all)
      @item._acl_records = notes
      @item._notification = @title.notification
      @item._bbs_title_name = @title.title
    end

    if @title.recognize == 0
      _update_plus_location @item, doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params
    else
      _update_after_save_recognizers(@item, doclib_db_alias(Doclibrary::Recognizer), doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params)
    end
  end

  def destroy
    item = doclib_db_alias(Doclibrary::Doc)
    @item = item.find(params[:id])

    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    destroy_atacched_files
    destroy_files

    @item._notification = @title.notification
    _destroy_plus_location @item,doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params
  end

  def edit_file_memo
    get_role_index
    return authentication_error(403) unless @is_readable

    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :id, params[:parent_id]
    Doclibrary::Doc
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_show(@item)

    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, @item.id unless @title.form_name == 'form002'
    item.and :parent_id, @item.category2_id if @title.form_name == 'form002'
    item.order  'id'
    @files = item.find(:all)

    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    @file = item.find(params[:id])
  end

  def docs_state_from_params
    case params[:state]
    when 'DRAFT'
      'draft'
    when 'RECOGNIZE'
      'recognize'
    when 'PUBLISH'
      'recognized'
    else
      'public'
    end
  end

  def search_files_index
    item = doclib_db_alias(Doclibrary::ViewAclFile)
    item = item.new
    item.id = nil
    item.and "doclibrary_view_acl_files.title_id", @title.id
    item.and "doclibrary_view_acl_files.docs_state", docs_state_from_params
    item.and item.get_keywords_condition(params[:kwd], :filename) unless params[:kwd].blank?

    case params[:state]
    when 'DATE'
      item.and "doclibrary_view_acl_files.section_code", params[:gcd] unless params[:gcd].blank?
      item.and "doclibrary_view_acl_files.category1_id", params[:cat] unless params[:cat].blank?
    when 'GROUP'
      item.and "doclibrary_view_acl_files.section_code", section_codes_narrow_down unless params[:gcd].blank?
      item.and "doclibrary_view_acl_files.category1_id", params[:cat] unless params[:cat].blank?
    when 'CATEGORY'
      item.and "doclibrary_view_acl_files.section_code", params[:gcd] unless params[:gcd].blank?
      item.and "doclibrary_view_acl_files.category1_id", category_ids_narrow_down unless params[:kwd].blank?
      item.and "doclibrary_view_acl_files.category1_id", params[:cat] unless params[:cat].blank? if params[:kwd].blank?
    when 'DRAFT', 'PUBLISH'
      item.and 'doclibrary_view_acl_files.section_code', Site.parent_user_groups.map{|g| g.code} unless @is_admin
    when 'RECOGNIZE'
      unless @is_admin
        item.and {|d|
          d.or "doclibrary_view_acl_files.section_code", Site.user_group.code
          d.or "doclibrary_recognizers.code", Site.user.code
          d.or "doclibrary_docs.creater_id", Site.user.code
        }
      end
    end

    item.and {|d|
      d.or {|d2|
        d2.and "doclibrary_view_acl_files.acl_flag", 0
      }
      if @is_admin
        d.or {|d2|
          d2.and "doclibrary_view_acl_files.acl_flag", 9
        }
      else
        d.or {|d2|
          d2.and "doclibrary_view_acl_files.acl_flag", 1
          d2.and "doclibrary_view_acl_files.acl_section_code", Site.parent_user_groups.map{|g| g.code}
        }
        d.or {|d2|
          d2.and "doclibrary_view_acl_files.acl_flag", 2
          d2.and "doclibrary_view_acl_files.acl_user_code", Site.user.code
        }
      end
    }

    case params[:state]
    when 'DATE'
      item.order "doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC, doclibrary_view_acl_files.filename"
    when 'GROUP'
      item.order "doclibrary_view_acl_files.section_code, doclibrary_view_acl_files.category1_id, doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC, doclibrary_view_acl_files.filename"
    else
      item.order "doclibrary_view_acl_files.filename, doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC"
    end

    item.join "LEFT JOIN doclibrary_recognizers ON doclibrary_view_acl_files.parent_id = doclibrary_recognizers.parent_id AND doclibrary_view_acl_files.title_id = doclibrary_recognizers.title_id"
    item.page params[:page], params[:limit]
    @files = item.find(:all)
  end

  def section_codes_narrow_down
    section_codes = []
    unless params[:gcd].blank?
      item = doclib_db_alias(Doclibrary::GroupFolder)
      item = item.new
      item.and :title_id, @title.id
      item.and :state, 'public'
      item.and :code, params[:gcd].to_s
      items = item.find(:all)
      section_codes += section_narrow(items) if items
    end
    section_codes
  end
  def section_narrow(items)
    section_codes = []
    items.each do |item|
      section_codes << item.code
      section_narrow(item.children) if item.children.size > 0
    end
    section_codes
  end

  def normal_category_index_form001
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and 'doclibrary_docs.state', 'public'
    item.and 'doclibrary_docs.title_id', @title.id
    item.and item.get_keywords_condition(params[:kwd], :title, :body) unless params[:kwd].blank?

    case params[:state]
    when 'DATE'
      item.and 'doclibrary_docs.section_code', params[:gcd] unless params[:gcd].blank?
      item.and 'doclibrary_docs.category1_id', params[:cat] unless params[:cat].blank?
    when 'GROUP'
      item.and 'doclibrary_docs.section_code', section_codes_narrow_down unless params[:gcd].blank?
      item.and 'doclibrary_docs.category1_id', params[:cat] unless params[:cat].blank?
    when 'CATEGORY'
      item.and 'doclibrary_docs.section_code', params[:gcd] unless params[:gcd].blank?
      item.and 'doclibrary_docs.category1_id', category_ids_narrow_down unless params[:kwd].blank?
      item.and 'doclibrary_docs.category1_id', params[:cat] unless params[:cat].blank? if params[:kwd].blank?
    end

    item.and {|d|
      d.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 0
      }
      if @is_admin
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 9
        }
      else
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 1
          d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
        }
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 2
          d2.and 'doclibrary_view_acl_docs.acl_user_code', Site.user.code
        }
      end
    }

    case params[:state]
    when 'DATE'
      item.order "doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title"
    when 'GROUP'
      item.order "doclibrary_docs.section_code, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC"
    else
      item.order "doclibrary_view_acl_docs.sort_no, section_code, doclibrary_docs.title, doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC"
    end

    item.join 'INNER JOIN doclibrary_view_acl_docs ON doclibrary_docs.id = doclibrary_view_acl_docs.id'
    item.page params[:page], params[:limit]
    select = "doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id"
    @items = item.find(:all, :select => select)
  end

  def category_ids_narrow_down
    cats = []
    unless params[:cat].blank?
      item = doclib_db_alias(Doclibrary::Folder)
      item = item.new
      item.and :title_id, @title.id
      item.and :state, 'public'
      item.and :id, params[:cat]
      items = item.find(:all, :select => 'id')
      cats += category_narrow(items) if items
    end
    cats
  end

  def category_narrow(items)
    cats = []
    items.each do |item|
      cats << item.id
      cats += category_narrow(item.children.find(:all, :conditions => {:state => 'public'}))
    end
    cats
  end

  def search_index_docs
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :state, 'public'
    item.and :title_id, params[:title_id]
    item.search params
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :order => "inpfld_001 , inpfld_002 DESC, inpfld_003, inpfld_004, inpfld_005, inpfld_006")
  end

  def normal_category_index
    category_folder_items if params[:kwd].blank?

    if @title.form_name == 'form002'
      normal_category_index_form002
    else
      normal_category_index_form001
    end
  end

  def category_folder_items(state=nil)
    item = doclib_db_alias(Doclibrary::Folder)
    folder = item.find_by_id(params[:cat])

    if folder.blank?
      level_no = 2
      parent_id = 1
    else
      level_no = folder.level_no + 1
      parent_id = folder.id
    end

    item = doclib_db_alias(Doclibrary::ViewAclFolder)
    item = item.new
    item.id = nil
    item.and :state, (state == 'draft' ? 'closed' : 'public')
    item.and :title_id, @title.id
    item.and :level_no, level_no unless state == 'draft'
    item.and :parent_id, parent_id unless state == 'draft'
    item.and {|d|
      d.or {|d2|
        d2.and :acl_flag, 0
      }
      if @is_admin
        d.or {|d2|
          d2.and :acl_flag, 9
        }
      else
        d.or {|d2|
          d2.and :acl_flag, 1
          d2.and :acl_section_code, Site.parent_user_groups.map{|g| g.code}
        }
        d.or {|d2|
          d2.and :acl_flag, 2
          d2.and :acl_user_code, Site.user.code
        }
      end
    }
    item.order "level_no, sort_no, id"
    item.page params[:page], params[:limit]
    @folders = item.find(:all)
  end

  def normal_category_index_form002
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :state, 'public'
    item.and :title_id, @title.id
    item.and :category1_id, params[:cat]
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => "inpfld_001, inpfld_002 DESC, inpfld_003 DESC, inpfld_004 DESC, inpfld_005, inpfld_006")
  end

  def normal_draft_index
    params[:gcd] = Site.user_group.code unless @is_admin

    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and 'doclibrary_docs.title_id', @title.id
    item.and 'doclibrary_docs.state', 'draft'
    item.and 'doclibrary_docs.section_code', params[:gcd].to_s unless params[:gcd].blank? unless @is_admin
    item.and item.get_keywords_condition(params[:kwd], :title, :body) unless params[:kwd].blank?
    item.and {|d|
      d.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 0
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      if @is_admin
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 9
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      else
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 1
          d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 2
          d2.and 'doclibrary_view_acl_docs.acl_user_code', Site.user.code
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      end
    }
    item.join 'INNER JOIN doclibrary_view_acl_docs ON doclibrary_docs.id = doclibrary_view_acl_docs.id INNER JOIN doclibrary_view_acl_folders ON doclibrary_docs.category1_id = doclibrary_view_acl_folders.id'
    item.order "doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title"
    item.page params[:page], params[:limit]
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id"
    @items = item.find(:all, :select => select)
  end

  def recognize_index
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and 'doclibrary_docs.title_id', @title.id
    item.and "doclibrary_docs.state", 'recognize'
    item.and item.get_keywords_condition(params[:kwd], :title, :body) unless params[:kwd].blank?
    item.and 'doclibrary_view_acl_folders.state', "public"
    item.and {|d|
      d.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 0
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      if @is_admin
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 9
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      else
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 1
          d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 2
          d2.and 'doclibrary_view_acl_docs.acl_user_code', Site.user.code
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      end
    }
    unless @is_admin
      item.and {|d|
        d.or "doclibrary_docs.section_code", Site.user_group.code
        d.or "doclibrary_recognizers.code", Site.user.code
        d.or "doclibrary_docs.creater_id", Site.user.code
      }
    end
    item.join "INNER JOIN doclibrary_recognizers ON doclibrary_docs.id = doclibrary_recognizers.parent_id AND doclibrary_docs.title_id = doclibrary_recognizers.title_id INNER JOIN doclibrary_view_acl_folders ON doclibrary_docs.category1_id = doclibrary_view_acl_folders.id INNER JOIN doclibrary_view_acl_docs ON doclibrary_docs.id = doclibrary_view_acl_docs.id "
    item.group_by 'doclibrary_docs.id'
    item.order 'latest_updated_at DESC'
    item.page params[:page], params[:limit]
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id"
    @items = item.find(:all, :select => select)
  end

  def recognized_index
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and 'doclibrary_docs.title_id', @title.id
    item.and 'doclibrary_docs.state', 'recognized'
    item.and 'doclibrary_docs.section_code', Site.parent_user_groups.map{|g| g.code} unless @is_admin
    item.and item.get_keywords_condition(params[:kwd], :title, :body) unless params[:kwd].blank?
    item.and {|d|
      d.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 0
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      if @is_admin
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 9
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      else
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 1
          d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
        d.or {|d2|
          d2.and 'doclibrary_view_acl_docs.acl_flag', 2
          d2.and 'doclibrary_view_acl_docs.acl_user_code', Site.user.code
          d2.and 'doclibrary_view_acl_folders.state', "public"
        }
      end
    }
    item.join 'inner join doclibrary_view_acl_docs on doclibrary_docs.id = doclibrary_view_acl_docs.id INNER JOIN doclibrary_view_acl_folders ON doclibrary_docs.category1_id = doclibrary_view_acl_folders.id'
    item.order "doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title"
    item.page params[:page], params[:limit]
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id"
    @items = item.find(:all, :select => select)
  end

  def normal_draft_index_form002
    item = doclib_db_alias(Doclibrary::Folder)
    folder = item.find_by_id(params[:cat])

    params[:cat] = 1 if folder.blank?
    level_no = 2 if folder.blank?
    parent_id = 1 if folder.blank?

    level_no = folder.level_no + 1 unless folder.blank?
    parent_id = folder.id unless folder.blank?

    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new
    item.and :state, 'public'
    item.and :title_id, @title.id
    item.and :level_no, level_no
    item.and :parent_id, parent_id
    item.page   params[:page], params[:limit]
    @folders = item.find(:all, :order=>"level_no, sort_no, id")

    str_order = "updated_at DESC, created_at DESC, category1_id, id" unless @title.form_name == 'form002'
    str_order = "inpfld_001 , inpfld_002 DESC, inpfld_003, inpfld_004, inpfld_005, inpfld_006" if @title.form_name == 'form002'
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :state, 'draft'
    item.and :title_id, @title.id
    item.and :category1_id, params[:cat]
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :order => str_order)
  end

  def set_folder_level_code

    item = doclib_db_alias(Doclibrary::GroupFolder)
    item = item.new
    item.and :title_id, @title.id
    item.and :level_no, 1
    item.and :state, 'public'
    items = item.find(:all,:order => 'level_no, sort_no, parent_id, id')
    @group_levels = []
    set_folder_hash('group', items)

    item = doclib_db_alias(Doclibrary::Folder)
    item = item.new
    item.and :title_id, @title.id
    item.and :level_no, 1
    items = item.find(:all,:order => 'level_no, sort_no, parent_id, id')
    @category_levels = []
    set_folder_hash('category', items)
    Doclibrary::GroupFolder.remove_connection
  end

  def set_folder_hash(mode, items)
    if items.size > 0
      items.each do |item|
        if item.state == 'public'
          tree = '+'
          tree += "-" * (item.level_no - 2) if 0 < (item.level_no - 2)
          @group_levels << [tree + item.code + item.name, item.code] if mode == 'group'
          @category_levels << [tree + item.name, item.id] if 1 <= item.level_no unless mode == 'group'
          case mode
          when 'group'
            children = item.children
          when 'category'
            children = item.readable_public_children(@is_admin)
          end
          set_folder_hash(mode, children)
        end
      end
    end
  end

  def section_folder_state_update
    group_item = doclib_db_alias(Doclibrary::GroupFolder)
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :state, 'public'
    item.and :title_id, @title.id
    item.find(:all, :select=>'section_code', :group => 'section_code').each do |code|
      g_item = group_item.new
      g_item.and :title_id, @title.id
      g_item.and :code, code.section_code
      g_item.find(:all).each do |group|
        group_state_rewrite(group,group_item)
      end
    end

  end

  def group_state_rewrite(item,group_item)
    group_item.update(item.id, :state =>'public')
    unless item.parent.blank?
      group_state_rewrite(item.parent, group_item)
    end
  end

  def form002_categories
    if @title.form_name == 'form002'
      @documents = []
      item = doclib_db_alias(Doclibrary::Category)
      item.find(:all, :conditions => {:state => 'public', :title_id => @title.id}, :order => 'id DESC').each do |dep|
        if dep.sono2.blank?
          str_sono = dep.sono.to_s
        else
          str_sono = "#{dep.sono.to_s} - #{dep.sono2.to_s}"
        end
        @documents << ["#{dep.wareki}#{dep.nen}年#{dep.gatsu}月その#{str_sono} : #{dep.filename}", dep.id]
      end
      Doclibrary::Category.remove_connection
    end
  end


  def set_form002_params
      item = doclib_db_alias(Doclibrary::Category)
      item = item.new
      item.and :id, @item.category2_id
      item = item.find(:first)
      if item
        @item.inpfld_001 = item.wareki
        @item.inpfld_002 = item.nen
        @item.inpfld_003 = item.gatsu
        @item.inpfld_004 = item.sono
        @item.inpfld_005 = item.sono2

        @item.inpfld_007 = "#{@item.inpfld_004.to_s} - #{item.sono2}" unless item.sono2.blank?
        @item.inpfld_007 = item.sono if item.sono2.blank?
      end
      Doclibrary::Category.remove_connection
  end

  def is_attach_new
    ret = false
    case @title.upload_system
    when 1..4
      ret = true
    end
    return ret
  end

  def return_form002_attached_url
    check = is_attach_new
    ret = ''
    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    item.and :title_id, @item.title_id
    item.and :parent_id, @item.category2_id
    file = item.find(:first)
    unless file.blank?
      ret = "#{file.file_uri(file.system_name)}" if check
      ret = "/_admin/gwboard/receipts/#{file.id}/download_object?system=#{file.system_name}&title_id=#{file.title_id}" unless check
    end
    Doclibrary::File.remove_connection
    return ret
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end

  def get_recogusers
    item = doclib_db_alias(Doclibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.order 'id'
    @recogusers = item.find(:all)
    Doclibrary::Recognizer.remove_connection
  end

  def publish_update
    item = doclib_db_alias(Doclibrary::Doc)
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
    Doclibrary::Doc.remove_connection
    redirect_to(doclibrary_docs_path({:title_id=>@title.id}))
  end

  def recognize_update
    item = doclib_db_alias(Doclibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:first)
    if item
      item.recognized_at = Time.now
      item.save
    end

    item = doclib_db_alias(Doclibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and "sql", "recognized_at IS NULL"
    item = item.find(:all)

    if item.length == 0
      item = doclib_db_alias(Doclibrary::Doc)
      item = item.find(params[:id])
      item.state = 'recognized'
      item.recognized_at = Time.now
      item.save

      user = System::User.find_by_code(item.editor_id.to_s)
      unless user.blank?
        Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{doclibrary_show_uri(item,params)}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
      end
    end
    Doclibrary::Recognizer.remove_connection
    get_role_new
    redirect_to("#{doclibrary_docs_path({:title_id=>@title.id})}") unless @is_writable
    redirect_to("#{doclibrary_docs_path({:title_id=>@title.id})}&state=RECOGNIZE") if @is_writable
  end

  def check_recognize
    item = doclib_db_alias(Doclibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item.and 'sql', "recognized_at is null"
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Doclibrary::Recognizer.remove_connection
    return ret
  end

  def check_recognize_readable
    item = doclib_db_alias(Doclibrary::Recognizer)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, params[:id]
    item.and :code, Site.user.code
    item = item.find(:all)
    ret = nil
    ret = true if item.length != 0
    Doclibrary::Recognizer.remove_connection
    return ret
  end


  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_atacched_files
    item = doclib_db_alias(Doclibrary::File)
    item.destroy_all(sql_where)
    Doclibrary::File.remove_connection
  end

  def destroy_files
    item = doclib_db_alias(Doclibrary::DbFile)
    item.destroy_all(sql_where)
    Doclibrary::DbFile.remove_connection
  end

end
