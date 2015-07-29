# -*- encoding: utf-8 -*-
module Gwbbs::Model::DbnameAlias

  def admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Core.user.id ,'gwbbs', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Core.user_group.id ,'gwbbs', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm

    unless @is_bbsadm
      item = Gwbbs::Adm.new
      item.and :user_id, 0
      item.and :group_code, Core.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      parent_group_code = ''
      parent_group_code = Core.user_group.parent.code unless Core.user_group.parent.blank?
      unless @is_bbsadm
        item = Gwbbs::Adm.new
        item.and :user_id, 0
        item.and :group_code, parent_group_code
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        @is_bbsadm = true unless items.blank?
      end unless parent_group_code.blank?

      unless @is_bbsadm
        item = Gwbbs::Adm.new
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

  def get_writable_flag
    @is_writable = true if @is_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwbbs::Role.find(:all, :order=>'group_code', :conditions => sql.where)
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

    unless @is_writable
      item = Gwbbs::Role.new
      item.and :role_code, 'w'
      item.and :title_id, @title.id
      item.and :user_code, Core.user.code
      item = item.find(:first)
      @is_writable = true if item.user_code == Core.user.code unless item.blank?
    end
  end

  def get_readable_flag
    @is_readable = true if @is_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      sql.and 'sql', 'user_id IS NULL'
      items = Gwbbs::Role.find(:all, :order=>'group_code', :conditions => sql.where)
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

    unless @is_readable
      item = Gwbbs::Role.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :user_code, Core.user.code
      item = item.find(:first)
      @is_readable = true if item.user_code == Core.user.code unless item.blank?
    end
  end

  def gwbbs_db_alias(item)
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
        cnn.spec.config[:database] = cn[0,i] + '_bbs'
      else
        cnn.spec.config[:database] = "dev_jgw_bbs"
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

  def clone_doc(item, options = {})
    _clone = item.class.new
    _clone.attributes = item.attributes
    _clone.id = nil
    _clone.unid = nil
    _clone.created_at = nil
    _clone.updated_at = nil
    _clone.recognized_at = nil
    _clone.published_at = nil
    _clone.state = 'draft'
    _clone.category4_id = 0
    _clone.name = nil
    _clone.latest_updated_at = Core.now
    _clone.createdate = nil
    _clone.creater_admin = nil
    _clone.createrdivision_id = nil
    _clone.createrdivision = nil
    _clone.creater_id = nil
    _clone.creater = nil
    _clone.editdate = nil
    _clone.editor_admin = nil
    _clone.editordivision_id = nil
    _clone.editordivision = nil
    _clone.editor_id = nil
    _clone.editor = nil
    _clone.able_date = Time.now.strftime("%Y-%m-%d")
    _clone.expiry_date = @title.default_published.months.since.strftime("%Y-%m-%d")

    _clone.section_code = Core.user_group.code

    group = Gwboard::Group.new
    group.and :code ,  _clone.section_code
    group.and :state , 'enabled'
    group = group.find(:first)
    _clone.section_name = group.code + group.name if group

    @before_state = item.state
    _clone.creater_admin = true
    _clone.editor_admin = false
    mode = ''
    mode = 'create' if _clone.createdate.blank?
    if @before_state == 'draft'
      mode = 'create'
    end if _clone.editdate.blank?
    if mode == 'create'
      _clone.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.creater_id = Core.user.code unless Core.user.code.blank?
      _clone.creater = Core.user.name unless Core.user.name.blank?
      _clone.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
      _clone.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.editor_id = Core.user.code unless Core.user.code.blank?
      _clone.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.creater_admin = true if @is_admin
      _clone.creater_admin = false unless @is_admin
      _clone.editor_admin = true if @is_admin          #1
      _clone.editor_admin = false unless @is_admin     #0
    else
      _clone.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.editor = Core.user.name unless Core.user.name.blank?
      _clone.editordivision = Core.user_group.name unless Core.user_group.name.blank?
      _clone.editor_id = Core.user.code unless Core.user.code.blank?
      _clone.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.editor_admin = true if @is_admin          #1
      _clone.editor_admin = false unless @is_admin     #0
    end

    respond_to do |format|
      if _clone.save
        @doc_body = _clone.body
        copy_attached_files(item, _clone)
        unless @doc_body == _clone.body
          _clone.body = @doc_body
          _clone.save
        end
        location = _clone.edit_path + gwbbs_params_set
        format.html { redirect_to location }
      else
        flash[:notice] = '複製できません'
        location = item.show_path + gwbbs_params_set
        format.html { redirect_to location }
      end
    end
  end

  def copy_attached_files(item, clone)
    f_item = gwbbs_db_alias(Gwbbs::File)
    f_item = f_item.new
    f_item.and :title_id, item.title_id
    f_item.and :parent_id, item.id
    f_item.order  'id'
    files = f_item.find(:all)
    for file in files
     _clone = file.class.new
     _clone.attributes = file.attributes
     _clone.id = nil
     _clone.parent_id = clone.id
     _clone.db_file_id = -1
     _clone.save
     begin
       FileUtils.mkdir_p(_clone.f_path) unless FileTest.exist?(_clone.f_path)
       FileUtils.cp(file.f_name, _clone.f_name)
       @doc_body = @doc_body.gsub(file.file_uri('gwbbs'), _clone.file_uri('gwbbs'))
     rescue
     end
    end

    f_item = gwbbs_db_alias(Gwbbs::File)
    total = f_item.sum(:size,:conditions => 'unid = 1')
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = f_item.sum(:size,:conditions => 'unid = 2')
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save

    Gwbbs::File.remove_connection

  end

  def is_integer(no)
    chg = no.to_s
    return chg.to_i
  end
end