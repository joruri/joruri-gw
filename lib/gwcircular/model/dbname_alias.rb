#encoding:utf-8
module Gwcircular::Model::DbnameAlias

  def gwcircular_select_status(params)
    str = ''
    case params[:cond]
    when "admin"
      str = "able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    when "void"
      str = "expiry_date < '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    else
      str = "able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    end
    return str
  end

  def admin_flags(title_id)
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,'gwcircular', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,'gwcircular', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm

    unless @is_bbsadm
      item = Gwcircular::Adm.new
      item.and :user_id, 0
      item.and :group_code, Site.user_group.code
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        item = Gwcircular::Adm.new
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

  def get_writable_flag

    @is_writable = true if @is_admin

    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwcircular::Role.find(:all, :order=>'group_code', :conditions => sql.where)
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
      item = Gwcircular::Role.new
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
      items = Gwcircular::Role.find(:all, :order=>'group_code', :conditions => sql.where)
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
      item = Gwcircular::Role.new
      item.and :role_code, 'r'
      item.and :title_id, @title.id
      item.and :user_code, Site.user.code
      item = item.find(:first)
      @is_readable = true if item.user_code == Site.user.code unless item.blank?
    end
  end

  def get_readable_doc_flag(show_item)
    return unless @is_readable unless @is_admin

    sql = Condition.new
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :doc_type , 0
      d.and :id , show_item.parent_id
      d.and :target_user_code , Site.user.code
    }
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :doc_type , 1
      d.and :parent_id , show_item.parent_id
      d.and :state ,'!=', 'preparation'
      d.and :target_user_code , Site.user.code
    }
    item = Gwcircular::Doc.new
    items = item.find(:all, :conditions=>sql.where, :select=>:id)
    @is_readable = false if items.count == 0
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

    _clone.section_code = Site.user_group.code

    group = Gwboard::Group.new
    group.and :code , _clone.section_code
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
      _clone.creater_id = Site.user.code unless Site.user.code.blank?
      _clone.creater = Site.user.name unless Site.user.name.blank?
      _clone.createrdivision = Site.user_group.name unless Site.user_group.name.blank?
      _clone.createrdivision_id = Site.user_group.code unless Site.user_group.code.blank?
      _clone.editor_id = Site.user.code unless Site.user.code.blank?
      _clone.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?
      _clone.creater_admin = true if @is_admin
      _clone.creater_admin = false unless @is_admin
      _clone.editor_admin = true if @is_admin          #1
      _clone.editor_admin = false unless @is_admin     #0
    else
      _clone.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.editor = Site.user.name unless Site.user.name.blank?
      _clone.editordivision = Site.user_group.name unless Site.user_group.name.blank?
      _clone.editor_id = Site.user.code unless Site.user.code.blank?
      _clone.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?
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
    f_item = Gwcircular::File.new
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

    total = Gwcircular::File.sum(:size,:conditions => 'unid = 1')
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = Gwcircular::File.sum(:size,:conditions => 'unid = 2')
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save
  end

  def is_integer(no)
    chg = no.to_s
    return chg.to_i
  end
end