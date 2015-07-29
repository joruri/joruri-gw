# encoding: utf-8
module System::Model::Base::Content
  def states
    {'public' => '公開', 'closed' => '非公開'}
  end

  def readable
    join_creator
    self.and "system_creators.group_id", Core.user_group.id
    return self
  end

  def editable
    join_creator
    self.and "system_creators.group_id", Core.user_group.id
    return self
  end

  def deletable
    join_creator
    self.and "system_creators.group_id", Core.user_group.id
    return self
  end

  def public
    self.and "#{self.class.table_name}.state", 'public'
    return self
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def public?
    return true
  end

  def bread_crumbs(crumbs, options = {})
    return crumbs
  end
end