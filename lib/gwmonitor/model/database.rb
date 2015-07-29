# -*- encoding: utf-8 -*-
module Gwmonitor::Model::Database

  def system_admin_flags
    @is_sysadm = true if System::Model::Role.get(1, Site.user.id ,'gwmonitor', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Site.user_group.id ,'gwmonitor', 'admin') unless @is_sysadm

  end

  def clone_doc(item, options = {})

    _clone = item.class.new
    _clone.attributes = item.attributes

    _clone.id = nil
    _clone.unid = nil
    _clone.content_id = nil
    _clone.state = 'preparation'
    _clone.created_at = nil
    _clone.updated_at = nil
    _clone.latest_updated_at = nil

    _clone.section_code = Site.user_group.code

    group = Gwboard::Group.new
    group.and :code , _clone.section_code
    group.and :state , 'enabled'
    group = group.find(:first)
    _clone.section_name = group.code + group.name if group
    _clone.section_sort = group.sort_no if group

    _clone.public_count = nil
    _clone.draft_count = nil

    _clone.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    _clone.creater_id = Site.user.code
    _clone.creater = Site.user.name
    _clone.createrdivision = Site.user_group.name
    _clone.createrdivision_id = Site.user_group.code

    _clone.editdate = nil
    _clone.editordivision_id = nil
    _clone.editordivision = nil
    _clone.editor_id = nil
    _clone.editor = nil
    _clone.default_limit = nil
    _clone.dsp_admin_name = nil
    _clone.send_change = nil
    _clone.custom_groups = nil
    _clone.custom_groups_json = nil
    _clone.reader_groups = nil
    _clone.reader_groups_json = nil
    _clone.custom_readers = nil
    _clone.custom_readers_json = nil
    _clone.readers = nil
    _clone.readers_json = nil


    respond_to do |format|
      if _clone.save
        @doc_body = _clone.caption
        copy_attached_files(item, _clone)
        unless @doc_body == _clone.caption
          _clone.caption = @doc_body
          _clone.save
        end

        location = _clone.edit_path
        format.html { redirect_to location }
      else
        flash[:notice] = '複製できません'
        location = options[:location]
        format.html { redirect_to location }
      end
    end
  end

  def copy_attached_files(item, clone)
    f_item = Gwmonitor::BaseFile
    f_item = f_item.new
    f_item.and :title_id, item.id
    f_item.and :parent_id, item.id
    f_item.order  'id'
    files = f_item.find(:all)
    for file in files
     _clone = file.class.new
     _clone.attributes = file.attributes
     _clone.id = nil
     _clone.title_id = clone.id
     _clone.parent_id = clone.id
     _clone.db_file_id = -1
     _clone.save
     begin
       FileUtils.mkdir_p(_clone.f_path) unless FileTest.exist?(_clone.f_path)
       FileUtils.cp(file.f_name, _clone.f_name)
       @doc_body = @doc_body.gsub(file.file_uri('gwmonitor_base'), _clone.file_uri('gwmonitor_base'))
     rescue
     end
    end

    f_item = Gwmonitor::BaseFile
    total = f_item.sum(:size,:conditions => 'unid = 1')
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = f_item.sum(:size,:conditions => 'unid = 2')
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save

  end

end