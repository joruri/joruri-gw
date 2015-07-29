module Gwboard::Model::DbnameAlias

  def gwboard_control
    case params[:system]
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

  def gwboard_doc
    case params[:system]
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
    return gwboard_db_alias(sys)
  end

  def gwboard_doc_close
    case params[:system]
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
    sys.remove_connection
  end

  def gwboard_image
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::Image
    when 'gwfaq'
      sys = Gwfaq::Image
    when 'gwqa'
      sys = Gwqa::Image
    when 'doclibrary'
      sys = Doclibrary::Image
    when 'digitallibrary'
      sys = Digitallibrary::Image
    else
    end
    return gwboard_db_alias(sys)
  end

  def gwboard_image_close
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::Image
    when 'gwfaq'
      sys = Gwfaq::Image
    when 'gwqa'
      sys = Gwqa::Image
    when 'doclibrary'
      sys = Doclibrary::Image
    when 'digitallibrary'
      sys = Digitallibrary::Image
    else
    end
    sys.remove_connection
  end

  def gwboard_file
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::File
    when 'gwfaq'
      sys = Gwfaq::File
    when 'gwqa'
      sys = Gwqa::File
    when 'doclibrary'
      sys = Doclibrary::File
    when 'digitallibrary'
      sys = Digitallibrary::File
    else
    end
    return gwboard_db_alias(sys)
  end

   def gwboard_file_close
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::File
    when 'gwfaq'
      sys = Gwfaq::File
    when 'gwqa'
      sys = Gwqa::File
    when 'doclibrary'
      sys = Doclibrary::File
    when 'digitallibrary'
      sys = Digitallibrary::File
    else
    end
    sys.remove_connection
  end

  def gwboard_db_file
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::DbFile
    when 'gwfaq'
      sys = Gwfaq::DbFile
    when 'gwqa'
      sys = Gwqa::DbFile
    when 'doclibrary'
      sys = Doclibrary::DbFile
    when 'digitallibrary'
      sys = Digitallibrary::DbFile
    else
    end
    return gwboard_db_alias(sys)
  end

  def gwboard_db_file_close
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::DbFile
    when 'gwfaq'
      sys = Gwfaq::DbFile
    when 'gwqa'
      sys = Gwqa::DbFile
    when 'doclibrary'
      sys = Doclibrary::DbFile
    when 'digitallibrary'
      sys = Digitallibrary::DbFile
    else
    end
    sys.remove_connection
  end
  #
  def gwboard_db_alias(item)
    title_id = params[:title_id]
    title_id = @title.id unless @title.blank?
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

  def admin_flags
    case params[:system]
    when 'gwbbs', 'gwfaq', 'gwqa', 'doclibrary', 'digitallibrary'
      system_name = params[:system]
    else
      return false
    end

    @is_readable = true if System::Model::Role.get(1, Core.user.id , system_name, 'admin')
    return @is_readable if @is_readable

    @is_readable = true if System::Model::Role.get(2, Core.user_group.id , system_name, 'admin') unless @is_readable
    return @is_readable if @is_readable

    unless @is_readable
      case params[:system]
      when 'gwbbs'
        base_item = Gwbbs::Adm
      when 'gwfaq'
        base_item = Gwfaq::Adm
      when 'gwqa'
        base_item = Gwqa::Adm
      when 'doclibrary'
        base_item = Doclibrary::Adm
      when 'digitallibrary'
        base_item = Digitallibrary::Adm
      else
      end
    end
    unless @is_readable
      item = base_item.new
      item.and :user_id, 0
      item.and :group_code, Core.user_group.code
      item.and :title_id, params[:title_id]
      items = item.find(:all)

      @is_readable = true unless items.blank?

      unless @is_readable
        item = base_item.new
        item.and :user_code, Core.user.code
        item.and :group_code, Core.user_group.code
        item.and :title_id, params[:title_id]
        items = item.find(:all)
        @is_readable = true unless items.blank?
      end
    end
  end

  def get_readable_flag
    unless @is_readable
      case params[:system]
      when 'gwbbs'
        base_item = Gwbbs::Role
      when 'gwfaq'
        base_item = Gwfaq::Role
      when 'gwqa'
        base_item = Gwqa::Role
      when 'doclibrary'
        base_item = Doclibrary::Role
      when 'digitallibrary'
        base_item = Digitallibrary::Role
      else
      end
    end

    unless @is_readable
      item = base_item.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :group_code, '0'
      items = item.find(:all)

      @is_readable = true unless items.blank?
    end

    parent_group_code = ''
    parent_group_code = Core.user_group.parent.code unless Core.user_group.parent.blank?
    unless @is_readable
      item = base_item.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :group_code, parent_group_code
      items = item.find(:all)

      @is_readable = true unless items.blank?
    end  unless parent_group_code.blank?

    unless @is_readable
      item = base_item.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :group_code, Core.user_group.code
      items = item.find(:all)
      @is_readable = true unless items.blank?
    end

    unless @is_readable
      item = base_item.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :user_code, Core.user.code
      items = item.find(:all)

      @is_readable = true unless items.blank?
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