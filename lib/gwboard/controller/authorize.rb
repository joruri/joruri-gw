module Gwboard::Controller::Authorize

  def parent_group_code
    item = System::Group.find_by_id(Core.user_group.parent_id) if Core.user_group.parent_id
    ret = item.code if item
    return ret
  end

  def get_editable_flag(item)
    @is_editable = true if @is_admin
    unless @is_editable

      get_writable_flag
      @is_editable = true if item.section_code == Core.user_group.code if @is_writable
    end
  end

  def get_role_index
    admin_flags(@title.id)
    get_readable_flag
    get_writable_flag
  end

  def get_role_show(item)
    admin_flags(@title.id)
    get_readable_flag
    get_editable_flag(item)
  end

  def get_role_edit(item)
    admin_flags(@title.id)
    get_editable_flag(item)
  end

  def get_role_new
    admin_flags(@title.id)
    get_writable_flag
  end

  def is_authorized(item)
    _compare = false
    unless item.blank?
      if authorized_person_only(item)

        _compare = true
      else
        _compare = true if @title.state == 'public'
      end
    end
    return _compare
  end

  def authorized_person_only(item)
    _compare = false
    unless item.creator.nil?
      _compare = true if Core.user.code == item.creater_id
    end
    return _compare
  end

  def admin_pp
    pp "@is_admin : #{@is_admin}"
    pp "@is_sysadm : #{@is_sysadm}"
    pp "@is_bbsadm : #{@is_bbsadm}"
    pp "@is_readable : #{@is_readable}"
    pp "@is_editable : #{@is_editable}"
    pp "@is_writable : #{@is_writable}"
  end

end