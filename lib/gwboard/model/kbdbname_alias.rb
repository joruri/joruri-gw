module Gwboard::Model::KbdbnameAlias

  def faq_admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Core.user.id ,'gwfaq', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Core.user_group.id ,'gwfaq', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm

    unless @is_bbsadm
      item = Gwfaq::Adm.new
      item.and :user_id, 0
      item.and :group_code, Core.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        item = Gwfaq::Adm.new
        item.and :user_code, Core.user.code
        item.and :group_code, Core.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        @is_bbsadm = true unless items.blank?
      end
    end

    @is_admin = true if @is_sysadm
    @is_admin = true if @is_bbsadm
  end

  def get_writable_flag_only
    faq_admin_flags(params[:title_id])
    faq_get_writable_flag
  end

  def faq_get_writable_flag
    @is_writable = true if @is_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwfaq::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'
        for group in Core.user.groups
          @is_writable = true if item.group_code == group.code
          @is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end
  end

  def faq_get_readable_flag
    @is_readable = true if @is_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      items = Gwfaq::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'
        for group in Core.user.groups
          @is_readable = true if item.group_code == group.code
          @is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end
  end

  def gwfaq_db_alias(item)

    title_id = params[:title_id]
    title_id = @title.id unless @title.blank?
    cnn = item.establish_connection
    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = @title.dbname unless @title.blank?

    unless dbname == ''
      cnn.spec.config[:database] = @title.dbname.to_s
    else
      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + '_faq'
      else
        cnn.spec.config[:database] = "dev_jgw_faq"
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

  def qa_admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Core.user.id ,'gwqa', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Core.user_group.id ,'gwqa', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm

    unless @is_bbsadm
      item = Gwqa::Adm.new
      item.and :user_id, 0
      item.and :group_code, Core.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        item = Gwqa::Adm.new
        item.and :user_code, Core.user.code
        item.and :group_code, Core.user_group.code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        @is_bbsadm = true unless items.blank?
      end
    end

    @is_admin = true if @is_sysadm
    @is_admin = true if @is_bbsadm
  end

  def qa_get_writable_flag
    @is_writable = true if @is_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwqa::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'
        for group in Core.user.groups
          @is_writable = true if item.group_code == group.code
          @is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end
  end

  def qa_get_readable_flag
    @is_readable = true if @is_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      items = Gwqa::Role.find(:all, :order=>'group_code', :conditions => sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'
        for group in Core.user.groups
          @is_readable = true if item.group_code == group.code
          @is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end
  end

  def gwqa_db_alias(item)

    title_id = params[:title_id]
    title_id = @title.id unless @title.blank?
    cnn = item.establish_connection

    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = @title.dbname unless @title.blank?

    unless dbname == ''
      cnn.spec.config[:database] = @title.dbname.to_s
    else
      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + '_qa'
      else
        cnn.spec.config[:database] = "dev_jgw_qa"
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