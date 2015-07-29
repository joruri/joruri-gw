# encoding: utf-8
class Gw::Tool::BoardAuth

  SYSTEMS = ["gwbbs", "gwfaq", "gwqa", "doclibrary", "digitallibrary"]
  TYPES = ["docs", "folders", "comments"]

  def self.valid_url?(url)
    system = type = tid = did = cat = nil
    state = action = ""

    SYSTEMS.each do |s|
      TYPES.each do |t|

        if url =~ %r{.*/#{s}/#{t}/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
          action = "edit"
          system = s
          type = t
          did = $1
          tid = $2
          cat = $3
          state = $4
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
          action = "edit"
          system = s
          type = t
          did = $1
          tid = $2
          state = $3
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)/edit[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
          action = "edit"
          system = s
          type = t
          did = $1
          tid = $2
          cat = $3
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)/edit[/?](?=.*title_id=(\d+))}
          action = "edit"
          system = s
          type = t
          did = $1
          tid = $2

        elsif url =~ %r{.*/#{s}/#{t}/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
          action = "show"
          system = s
          type = t
          did = $1
          tid = $2
          cat = $3
          state = $4
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
          action = "show"
          system = s
          type = t
          did = $1
          tid = $2
          cat = $3
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
          action = "show"
          system = s
          type = t
          did = $1
          tid = $2
          state = $3
        elsif url =~ %r{.*/#{s}/#{t}/(\d+)[/?](?=.*title_id=(\d+))}
          action = "show"
          system = s
          type = t
          did = $1
          tid = $2

        elsif url =~ %r{.*/#{s}/#{t}/new[/?](?=.*title_id=(\d+))(?=.*p_id=(\d+))}
          action = "new"
          system = s
          type = t
          tid = $1
          did = $2
        elsif url =~ %r{.*/#{s}/#{t}/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
          action = "new"
          system = s
          type = t
          tid = $1
          cat = $2
          state = $3
        elsif url =~ %r{.*/#{s}/#{t}/new[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))}
          action = "new"
          system = s
          type = t
          tid = $1
          cat = $2
        elsif url =~ %r{.*/#{s}/#{t}/new[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
          action = "new"
          system = s
          type = t
          tid = $1
          state = $2
        elsif url =~ %r{.*/#{s}/#{t}/new[/?](?=.*title_id=(\d+))}
          action = "new"
          system = s
          type = t
          tid = $1

        elsif url =~ %r{.*/#{s}/#{t}[/?](?=.*title_id=(\d+))(?=.*cat=(\d+))(?=.*state=(\w+))}
          action = "index"
          system = s
          type = t
          tid = $1
          cat = $2
          state = $3
        elsif url =~ %r{.*/#{s}/#{t}[/?](?=.*title_id=(\d+))(?=.*state=(\w+))}
          action = "index"
          system = s
          type = t
          tid = $1
          state = $2
        elsif url =~ %r{.*/#{s}/#{t}[/?](?=.*title_id=(\d+))}
          action = "index"
          system = s
          type = t
          tid = $1
        end
        break if system != nil
      end
      break if system != nil
    end

    pp [url, system, action, type, tid, did, cat, state]

    options = {}
    options[:state] = state
    options[:cat] = cat

    if action == 'new' || action == 'edit'

      if system && tid && did && type == 'docs'
        return self.writable_doc?(system, tid.to_i, did.to_i, options)
      elsif system && tid && did && type == 'folders'
        return self.writable_folder?(system, tid.to_i, did.to_i, options)
      elsif system && tid
        return self.writable_board?(system, tid.to_i, options)
      end
    else

      if system && tid && did && type == 'docs'
        return self.readable_doc?(system, tid.to_i, did.to_i, options)
      elsif system && tid && did && type == 'folders'
        return self.readable_folder?(system, tid.to_i, did.to_i, options)
      elsif system && tid
        return self.readable_board?(system, tid.to_i, options)
      end
    end

    return true
  end

  def self.get_title(system, title_id)
    item = self.gwboard_news_control(system)
    item = item.new
    item.and :state, 'public'
    item.and :id, title_id
    title = item.find(:first)
    return title
  end

  def self.get_titles(system)
    item = self.gwboard_news_control(system)
    item = item.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.order 'sort_no'
    return item.find(:all)
  end

  def self.readable_board?(system, title_id, options=nil)
    title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_readable = true
    else
      is_readable = self.get_readable_flag(system, title)
    end
    return is_readable
  end

  def self.readable_doc?(system, title_id, doc_id, options)
    title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_readable = true
    else
      is_readable = self.get_readable_flag(system, title)
    end

    if is_readable
      options[:is_admin] = is_admin
      case system
        when 'gwbbs'
          docs = self.gwbbs_docs(system, title, doc_id, options)
        when 'gwfaq'
          docs = self.gwfaq_docs(system, title, doc_id, options)
        when 'gwqa'
          docs = self.gwqa_docs(system, title, doc_id, options)
        when 'doclibrary'
          docs = self.doclibrary_docs(system, title, doc_id, options)
        when 'digitallibrary'
          docs = self.digitallibrary_docs(system, title, doc_id, options)
      end
      if docs.blank?
        is_readable = false
      else
        is_readable = true
      end
    end
    return is_readable
  end

  def self.readable_folder?(system, title_id, folder_id, options)
    title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_readable = true
    else
      is_readable = self.get_readable_flag(system, title)
    end

    if is_readable
      options[:is_admin] = is_admin
      case system
        when 'doclibrary'
          folders = self.doclibrary_folders(system, title, folder_id, options)
        when 'digitallibrary'
          folders = self.digitallibrary_folders(system, title, folder_id, options)
      end
      if folders.blank?
        is_readable = false
      else
        is_readable = true
      end
    end
    return is_readable
  end

  def self.writable_board?(system, title_id, options=nil)
   title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_writable = true
    else
      is_writable = self.get_writable_flag(system, title)
    end
    if is_writable
      if options && options[:cat]
        folder_id = options[:cat].to_i
        options.delete(:cat)
        case system
          when 'doclibrary'
            folders = self.doclibrary_folders(system, title, folder_id, options)
          when 'digitallibrary'
            folders = self.digitallibrary_folders(system, title, folder_id, options)
        end
        if folders.blank?
          is_writable = false
        else
          is_writable = true
        end
      end
    end
    return is_writable
  end

  def self.writable_doc?(system, title_id, doc_id, options)
    title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_writable = true
    else
      is_writable = self.get_writable_flag(system, title)
    end
    if is_writable
      options[:is_admin] = is_admin
      case system
        when 'gwbbs'
          docs = self.gwbbs_docs(system, title, doc_id, options)
        when 'gwfaq'
          docs = self.gwfaq_docs(system, title, doc_id, options)
        when 'gwqa'
          docs = self.gwqa_docs(system, title, doc_id, options)
        when 'doclibrary'
          docs = self.doclibrary_docs(system, title, doc_id, options)
        when 'digitallibrary'
          docs = self.digitallibrary_docs(system, title, doc_id, options)
      end
      if docs.blank?
        is_writable = false
      else
        is_writable = true
      end
    end
    return is_writable
  end

  def self.writable_folder?(system, title_id, folder_id, options)
    title = self.get_title(system, title_id)
    return false if title.blank?
    is_admin = self.get_admin_flag(system, title.id)
    if is_admin
      is_writable = true
    else
      is_writable = self.get_writable_flag(system, title)
    end
    if is_writable
      options[:is_admin] = is_admin
      case system
        when 'doclibrary'
          folders = self.doclibrary_folders(system, title, folder_id, options)
        when 'digitallibrary'
          folders = self.digitallibrary_folders(system, title, folder_id, options)
      end
      if folders.blank?
        is_writable = false
      else
        is_writable = true
      end
    end
    return is_writable
  end

  def self.gwbbs_docs(system, title, doc_id, options)
    item = self.gwboard_news_doc(system, title).new
    item.and :id, doc_id
    item.and :title_id, title.id
    if options[:state]
      case options[:state]
        when 'DRAFT'
          item.and :state, 'draft'
        when 'NEVER'
          item.and :state, 'public'
          item.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' < gwbbs_docs.able_date"
        when 'VOID'
          item.and :state, 'public'
          item.and 'sql', "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' > gwbbs_docs.expiry_date"
        when 'RECOGNIZE'
          item.and :state, 'recognize'
        when 'PUBLISH'
          item.and :state, 'recognized'
        else
          item.and :state, 'public'
      end
    end

    if title.restrict_access
      item.and " AND gwbbs_docs.section_code = '#{Site.user_group.code}'"
    end
    items = item.find(:all)
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.gwfaq_docs(system, title, doc_id, options)
    item = self.gwboard_news_doc(system, title).new
    item.and :id, doc_id
    item.and :title_id, title.id
    if options[:state]
      case options[:state]
        when 'TODAY'
          item.and :state, 'public'
          item.and 'sql', "'#{Time.now.strftime('%Y-%m-%d')} 00:00:00' < gwfaq_docs.latest_updated_at AND gwfaq_docs.latest_updated_at < '#{Time.now.strftime('%Y-%m-%d')} 23:59:59'"
        when 'DRAFT'
          item.and :state, 'draft'
        else
          item.and :state, 'public'
      end
    end
    items = item.find(:all)
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.gwqa_docs(system, title, doc_id, options)
    item = self.gwboard_news_doc(system, title).new
    item.and :id, doc_id
    item.and :title_id, title.id
    item.and :doc_type, 0
    if options[:state]
      case options[:state]
        when 'TODAY'
          item.and :state, 'public'
          item.and 'sql', "'#{Time.now.strftime('%Y-%m-%d')} 00:00:00' < gwqa_docs.latest_updated_at AND gwqa_docs.latest_updated_at < '#{Time.now.strftime('%Y-%m-%d')} 23:59:59'"
        when 'DRAFT'
          item.and :state, 'draft'
        else
          item.and :state, 'public'
      end
    end
    items = item.find(:all)
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.doclibrary_docs(system, title, doc_id, options)
    if title.form_name == 'form001'
      return self.doclibrary_form001(system, title, doc_id, options)
    else
      return self.doclibrary_form002(system, title, doc_id, options)
    end
  end

  def self.doclibrary_form001(system, title, doc_id, options)
    p_grp_code = ''
    p_grp_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    grp_code = ''
    grp_code = Site.user_group.code

    item = self.gwboard_news_doc(system, title).new
    sql = Condition.new
    sql.or {|d|
      d.and 'doclibrary_docs.id' , doc_id
      d.and 'doclibrary_docs.title_id' , title.id
      d.and 'doclibrary_view_acl_docs.acl_flag' , 0
    }
    if options[:is_admin]
      sql.or {|d|
        d.and 'doclibrary_docs.id' , doc_id
        d.and 'doclibrary_docs.title_id' , title.id
        d.and 'doclibrary_view_acl_docs.acl_flag' , 9
      }
    else
      sql.or {|d|
        d.and 'doclibrary_docs.id' , doc_id
        d.and 'doclibrary_docs.title_id' , title.id
        d.and 'doclibrary_view_acl_docs.acl_flag' , 1
        d.and 'doclibrary_view_acl_docs.acl_section_code' , p_grp_code
      }

      sql.or {|d|
        d.and 'doclibrary_docs.id' , doc_id
        d.and 'doclibrary_docs.title_id' , title.id
        d.and 'doclibrary_view_acl_docs.acl_flag' , 1
        d.and 'doclibrary_view_acl_docs.acl_section_code' , grp_code
      }

      sql.or {|d|
        d.and 'doclibrary_docs.id' , doc_id
        d.and 'doclibrary_docs.title_id' , title.id
        #d.and 'doclibrary_docs.state', 'public'
        d.and 'doclibrary_view_acl_docs.acl_flag' , 2
        d.and 'doclibrary_view_acl_docs.acl_user_code' , Site.user.code
      }
    end

    if options[:state]
      case options[:state]
        when 'DRAFT'
          sql.and 'doclibrary_docs.state', 'draft'
        else
          sql.and 'doclibrary_docs.state', 'public'
      end
    end

    if options[:cat]
      cat = options[:cat].to_i
      sql.and 'sql', "doclibrary_docs.category1_id=#{cat} OR doclibrary_docs.category2_id=#{cat} OR doclibrary_docs.category3_id=#{cat} OR doclibrary_docs.category4_id=#{cat}"
    end
    items = item.find(:all, :conditions=>sql.where, :select=>'doclibrary_docs.*' ,:joins => ['inner join doclibrary_view_acl_docs on doclibrary_docs.id = doclibrary_view_acl_docs.id'])
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.doclibrary_form002(system, title, doc_id, options)
    item = self.gwboard_news_doc(system, title).new
    item.and :id, doc_id
    item.and :title_id, title.id

    if options[:state]
      case options[:state]
        when 'DRAFT'
          item.and :state, 'draft'
        else
          item.and :state, 'public'
      end
    end

    if options[:cat]
      cat = options[:cat].to_i
      sql.and 'sql', "doclibrary_docs.category1_id=#{cat} OR doclibrary_docs.category2_id=#{cat} OR doclibrary_docs.category3_id=#{cat} OR doclibrary_docs.category4_id=#{cat}"
    end
    items = item.find(:all)
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.digitallibrary_docs(system, title, doc_id, options)
    item = self.gwboard_news_doc(system, title).new
    item.and :id, doc_id
    item.and :title_id, title.id
    item.and :doc_type, 1

    if options[:state]
      case options[:state]
        when 'DRAFT'
          item.and :state, 'draft'
        else
          item.and :state, 'public'
      end
    end

    if options[:cat]
      item.and :parent_id, options[:cat].to_i
    end
    items = item.find(:all)
    self.gwboard_news_doc_close(system)
    return items
  end

  def self.doclibrary_folders(system, title, folder_id, options)
    if title.form_name == 'form001'
      self.doclibrary_folder_form001(system, title, folder_id, options)
    else
      self.doclibrary_folder_form002(system, title, folder_id, options)
    end
  end

  def self.doclibrary_folder_form001(system, title, folder_id, options)
    p_grp_code = ''
    p_grp_code = Site.user_group.parent.code unless Site.user_group.parent.blank?
    grp_code = ''
    grp_code = Site.user_group.code

    item = self.gwboard_news_folder(system, title).new
    sql = Condition.new

    sql.or {|d|
      d.and 'doclibrary_folders.id' , folder_id
      d.and 'doclibrary_folders.title_id' , title.id
      d.and 'doclibrary_view_acl_folders.acl_flag' , 0
    }
    if options[:is_admin]
      sql.or {|d|
        d.and 'doclibrary_folders.id' , folder_id
        d.and 'doclibrary_folders.title_id' , title.id
        d.and 'doclibrary_view_acl_folders.acl_flag' , 9
      }
    else

      sql.or {|d|
        d.and 'doclibrary_folders.id' , folder_id
        d.and 'doclibrary_folders.title_id' , title.id
        d.and 'doclibrary_view_acl_folders.acl_flag' , 1
        d.and 'doclibrary_view_acl_folders.acl_section_code' , p_grp_code
      }

      sql.or {|d|
        d.and 'doclibrary_folders.id' , folder_id
        d.and 'doclibrary_folders.title_id' , title.id
        d.and 'doclibrary_view_acl_folders.acl_flag' , 1
        d.and 'doclibrary_view_acl_folders.acl_section_code' , grp_code
      }

      sql.or {|d|
        d.and 'doclibrary_folders.id' , folder_id
        d.and 'doclibrary_folders.title_id' , title.id
        d.and 'doclibrary_view_acl_folders.acl_flag' , 2
        d.and 'doclibrary_view_acl_folders.acl_user_code' , Site.user.code
      }
    end

    if options[:cat]
      item.and :parent_id, options[:cat].to_i
    end
    items = item.find(:all, :conditions=>sql.where, :select=>'doclibrary_folders.*' ,:joins => ['inner join doclibrary_view_acl_folders on doclibrary_folders.id = doclibrary_view_acl_folders.id'])
    self.gwboard_news_folder_close(system)
    return items
  end

  def self.doclibrary_folder_form002(system, title, folder_id, options)
    item = self.gwboard_news_folder(system, title).new
    item.and :id, folder_id
    item.and :title_id, title.id
    items = item.find(:all)

    if options[:cat]
      item.and :parent_id, options[:cat].to_i
    end
    self.gwboard_news_folder_close(system)
    return items
  end

  def self.digitallibrary_folders(system, title, folder_id, options)
    item = self.gwboard_news_folder(system, title).new
    item.and :id, folder_id
    item.and :title_id, title.id
    item.and :doc_type, 0

    if options[:cat]
      item.and :parent_id, options[:cat].to_i
    end
    items = item.find(:all)
    self.gwboard_news_folder_close(system)
    return items
  end

  def self.gwboard_news_control(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Control
      when 'gwfaq'
        sys = Gwfaq::Control
      when 'gwqa'
        sys = Gwqa::Control
      when 'doclibrary'
        sys = Doclibrary::Control
      when 'digitallibrary'
        sys = Digitallibrary::Control
      else
    end
    return sys
  end

  def self.item_system_adm(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Adm
      when 'gwfaq'
        sys = Gwfaq::Adm
      when 'gwqa'
        sys = Gwqa::Adm
      when 'doclibrary'
        sys = Doclibrary::Adm
      when 'digitallibrary'
        sys = Digitallibrary::Adm
      else
    end
    return sys
  end

  def self.item_system_role(system)
    case system
      when 'gwbbs'
        sys = Gwbbs::Role
      when 'gwfaq'
        sys = Gwfaq::Role
      when 'gwqa'
        sys = Gwqa::Role
      when 'doclibrary'
        sys = Doclibrary::Role
      when 'digitallibrary'
        sys = Digitallibrary::Role
      else
    end
    return sys
  end

  def self.gwboard_news_doc(system, title)
    case system
      when 'gwbbs'
        sys = Gwbbs::Doc
      when 'gwfaq'
        sys = Gwfaq::Doc
      when 'gwqa'
        sys = Gwqa::Doc
      when 'doclibrary'
        sys = Doclibrary::Doc
      when 'digitallibrary'
        sys = Digitallibrary::Doc
      else
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_news_doc_close(system)
    case system
      when 'gwbbs'
        Gwbbs::Doc.remove_connection
      when 'gwfaq'
        Gwfaq::Doc.remove_connection
      when 'gwqa'
        Gwqa::Doc.remove_connection
      when 'doclibrary'
        Doclibrary::Doc.remove_connection
      when 'digitallibrary'
        Digitallibrary::Doc.remove_connection
      else
    end
  end

  def self.gwboard_news_folder(system, title)
    case system
      when 'doclibrary'
        sys = Doclibrary::Folder
      when 'digitallibrary'
        sys = Digitallibrary::Folder
      else
    end
    return gwboard_db_alias2(sys, title)
  end

  def self.gwboard_news_folder_close(system)
    case system
      when 'doclibrary'
        Doclibrary::Folder.remove_connection
      when 'digitallibrary'
        Digitallibrary::Folder.remove_connection
      else
    end
  end

protected

  def self.gwboard_db_alias2(item, title)

    cnn = item.establish_connection

    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = title.dbname unless title.blank?
    unless dbname == ''
      cnn.spec.config[:database] = title.dbname.to_s
    else
      dbstr = ''
      dbstr = '_qa' if item.table_name.index("gwqa_")
      dbstr = '_bbs' if item.table_name.index("gwbbs_")
      dbstr = '_faq' if item.table_name.index("gwfaq_")
      dbstr = '_doc' if item.table_name.index("doclibrary_")
      dbstr = '_dig' if item.table_name.index("digitallibrary_")

      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + dbstr
      else
        cnn.spec.config[:database] = "dev_jgw" + dbstr
      end

      unless title.id.blank?
        if self.is_integer(title_id)
          cnn.spec.config[:database] +=  '_' + sprintf("%06d", title_id)
        end
      end
    end
    item::Gwboard::CommonDb.establish_connection(cnn.spec)

    return item

  end

  def self.get_admin_flag(system, title_id)
    is_sysadm = true if System::Model::Role.get(1, Site.user.id ,system, 'admin')
    is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,system, 'admin') unless is_sysadm
    is_bbsadm = true if is_sysadm

    unless is_bbsadm
      item = item_system_adm(system)
      item = item.new
      item.and :user_id, 0
      item.and :group_code, Site.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      is_bbsadm = true unless items.blank?

      unless is_bbsadm
        item = item_system_adm(system)
        item = item.new
        item.and :user_code, Site.user.code
        item.and :group_code, Site.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        is_bbsadm = true unless items.blank?
      end
    end

    is_admin = true if is_sysadm
    is_admin = true if is_bbsadm
    return is_admin
  end

  def self.get_writable_flag(system, title)
    is_writable = false
    sql = Condition.new
    sql.and :role_code, 'w'
    sql.and :title_id, title.id
    r_item = self.item_system_role(system)
    items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
    items.each do |item|
      is_writable = true if item.group_code == '0'
      for group in Site.user.groups
        is_writable = true if item.group_code == group.code
        is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
        break if is_writable
      end
      break if is_writable
    end
    unless is_writable
      item = self.item_system_role(system)
      item = item.new
      item.and :role_code, 'w'
      item.and :title_id, title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      is_writable = true if item.user_code == Site.user.code unless item.blank?
    end
    return is_writable
  end

  def self.get_readable_flag(system, title)
    is_readable = false
    sql = Condition.new
    sql.and :role_code, 'r'
    sql.and :title_id, title.id
    sql.and 'sql', 'user_id IS NULL'
    r_item = self.item_system_role(system)
    items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
    items.each do |item|
      is_readable = true if item.group_code == '0'
      for group in Site.user.groups
        is_readable = true if item.group_code == group.code
        is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
        break if is_readable
      end
      break if is_readable
    end

    unless is_readable
      item = self.item_system_role(system)
      item = item.new
      item.and :role_code, 'r'
      item.and :title_id, title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      is_readable = true if item.user_code == Site.user.code unless item.blank?
    end
    return is_readable
  end

  def self.is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end
end
