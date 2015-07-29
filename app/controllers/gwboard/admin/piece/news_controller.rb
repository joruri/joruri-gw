# encoding: utf-8
class Gwboard::Admin::Piece::NewsController < ApplicationController
  layout 'base'

  def gwboard_news_control(system)
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

  def index
    @portal_mode = Gw::AdminMode.portal_mode
    @portal_disaster_bbs = Gw::AdminMode.portal_disaster_bbs

    piece_parms = params[:piece_param].split(/_/)
    system = piece_parms[0]
    @system = system
    @title = nil
    title_id = piece_parms[1].to_i
    return nil unless system == 'gwbbs'
    @limit_portal = 11
    @limit_portal = 4 if request.mobile?

    item = gwboard_news_control(system)
    item = item.new
    item.and :state, 'public'
    item.and :id, title_id
    @title = item.find(:first)
    return if @title.blank?
    @limit  = nz(@title.default_limit,10)
    @page   = 1

    unless @title.blank?
      admin_flags(@title.id)
      get_writable_flag
      get_readable_flag
      unless @is_readable
        @title = nil
        return nil
      end

      item = gwboard_news_doc(system, title_id)
      item = item.new
      item.and :state, 'public'

      item.and 'sql'," (( able_date is NULL ) or ( able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' ))"
      item.and 'sql'," (( expiry_date is NULL ) or ( expiry_date >= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' ))"

      item.and :title_id, title_id
      item.order  'latest_updated_at DESC, id'
      item.page @page, @limit_portal
      @items = item.find(:all)
      gwboard_news_doc_close(system)
    end
  end

  def gwboard_news_doc(system, title_id)
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
    return gwboard_db_alias2(sys, title_id)
  end

  def gwboard_news_doc_close(system)
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

  def gwboard_db_alias2(item, title_id)

    cnn = item.establish_connection

    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = @title.dbname unless @title.blank?
    unless dbname == ''
      cnn.spec.config[:database] = @title.dbname.to_s
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

      unless title_id.blank?
        if is_integer(title_id)
          cnn.spec.config[:database] +=  '_' + sprintf("%06d", title_id)
        end
      end
    end

    Gwboard::CommonDb.establish_connection(cnn.spec.config)

    return item
  end

  def item_system_adm
    case @system
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
  def admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,@system, 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,@system, 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm

    unless @is_bbsadm
      item = item_system_adm
      item = item.new
      item.and :user_id, 0
      item.and :group_code, Site.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        item = item_system_adm
        item = item.new
        item.and :user_code, Site.user.code
        item.and :group_code, Site.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        @is_bbsadm = true unless items.blank?
      end
    end

    @is_admin = true if @is_sysadm
    @is_admin = true if @is_bbsadm
  end

  def item_system_role
    case @system
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

  def get_writable_flag
    @is_writable = true if @is_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      r_item = item_system_role
      items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'
        for group in Site.user.groups
          @is_writable = true if item.group_code == group.code
          @is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end
    unless @is_writable
      item = item_system_role
      item = item.new
      item.and :role_code, 'w'
      item.and :title_id, @title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      @is_writable = true if item.user_code == Site.user.code unless item.blank?
    end
  end

  def get_readable_flag
    @is_readable = true if @is_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      sql.and 'sql', 'user_id IS NULL'
      r_item = item_system_role
      items = r_item.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'
        for group in Site.user.groups
          @is_readable = true if item.group_code == group.code
          @is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end

    unless @is_readable
      item = item_system_role
      item = item.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      @is_readable = true if item.user_code == Site.user.code unless item.blank?
    end
  end

  def is_integer(no)
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