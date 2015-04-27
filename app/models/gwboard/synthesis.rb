class Gwboard::Synthesis < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  
  def gwbbs_readable_syntheses(date)
    is_sysadm = Core.user.has_role?('gwbbs/admin')
    
    self.and 'gwboard_syntheses.state', 'public'
    self.and 'gwboard_syntheses.system_name', 'gwbbs'
    self.and 'gwboard_syntheses.latest_updated_at', '>=', date
    self.and "sql", "'#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' BETWEEN able_date AND expiry_date"
    unless is_sysadm
      gcodes = Core.user.groups_and_ancestors.map(&:code)
      self.and {|d|
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", %w(r w a)
          d2.and "gwbbs_roles.user_id", 'IS', nil
          d2.and "gwbbs_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", %w(r w a)
          d2.and "gwbbs_roles.user_id", 'IS', nil
          d2.and "gwbbs_roles.group_code", gcodes
        }
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", %w(r w a)
          d2.and "gwbbs_roles.user_code", Core.user.code
        }
      }
      self.and do |d|
        d.or do |d2|
          d2.and 'gwbbs_controls.restrict_access', 0
        end
        d.or do |d2|
          d2.and 'gwbbs_controls.restrict_access', 1
          d2.and "gwboard_syntheses.acl_section_code", Core.user_group.code
        end
      end
    end
    
    self.join "LEFT JOIN gwbbs_roles ON gwboard_syntheses.title_id = gwbbs_roles.title_id"
    self.join "LEFT JOIN gwbbs_controls ON gwboard_syntheses.title_id = gwbbs_controls.id"
    self.group_by "gwboard_syntheses.id"
  end
  
  def gwfaq_readable_syntheses(date)
    is_sysadm = Core.user.has_role?('gwfaq/admin')
    
    self.and :state, 'public'
    self.and :system_name , 'gwfaq'
    self.and :latest_updated_at , '>=' , date
    unless is_sysadm
      gcodes = Core.user.groups_and_ancestors.map(&:code)
      self.and {|d|
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", %w(r w a)
          d2.and "gwfaq_roles.user_id", 'IS', nil
          d2.and "gwfaq_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", %w(r w a)
          d2.and "gwfaq_roles.user_id", 'IS', nil
          d2.and "gwfaq_roles.group_code", gcodes
        }
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", %w(r w a)
          d2.and "gwfaq_roles.user_code", Core.user.code
        }
      }
    end
    
    self.join "LEFT JOIN gwfaq_roles ON gwboard_syntheses.title_id = gwfaq_roles.title_id"
    self.group_by 'gwboard_syntheses.id'
  end
  
  def gwqa_readable_syntheses(date)
    is_sysadm = Core.user.has_role?('gwqa/admin')
    
    self.and :state, 'public'
    self.and :system_name, 'gwqa'
    self.and :latest_updated_at, '>=' , date
    unless is_sysadm
      gcodes = Core.user.groups_and_ancestors.map(&:code)
      self.and {|d|
        d.or {|d2|
          d2.and "gwqa_roles.role_code", %w(r w a)
          d2.and "gwqa_roles.user_id", 'IS', nil
          d2.and "gwqa_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwqa_roles.role_code", %w(r w a)
          d2.and "gwqa_roles.user_id", 'IS', nil
          d2.and "gwqa_roles.group_code", gcodes
        }
        d.or {|d2|
          d2.and "gwqa_roles.role_code", %w(r w a)
          d2.and "gwqa_roles.user_code", Core.user.code
        }
      }
    end
    
    self.join "LEFT JOIN gwqa_roles ON gwboard_syntheses.title_id = gwqa_roles.title_id"
    self.group_by 'gwboard_syntheses.id'
  end
  
  def doclibrary_readable_syntheses(date)
    is_sysadm = Core.user.has_role?('doclibrary/admin')
    
    self.and :state, 'public'
    self.and :system_name, 'doclibrary'
    self.and :latest_updated_at, '>=', date
    unless is_sysadm
      gcodes = Core.user.groups_and_ancestors.map(&:code)
      self.and {|d|
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", %w(r w a)
          d2.and "doclibrary_roles.user_id", 'IS', nil
          d2.and "doclibrary_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", %w(r w a)
          d2.and "doclibrary_roles.user_id", 'IS', nil
          d2.and "doclibrary_roles.group_code", gcodes
        }
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", %w(r w a)
          d2.and "doclibrary_roles.user_code", Core.user.code
        }
      }
      self.and {|d|
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 0
        }
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 1
          d2.and "gwboard_syntheses.acl_section_code", gcodes
        }
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 2
          d2.and "gwboard_syntheses.acl_user_code", Core.user.code
        }
      }
    end
    
    self.join "LEFT JOIN doclibrary_roles ON gwboard_syntheses.title_id = doclibrary_roles.title_id"
    self.group_by "gwboard_syntheses.title_id"
    self.group_by "gwboard_syntheses.parent_id"
  end
  
  def digitallibrary_readable_syntheses(date)
    is_sysadm = Core.user.has_role?('digitallibrary/admin')
    
    self.and :state, 'public'
    self.and :system_name, 'digitallibrary'
    self.and :latest_updated_at, '>=', date
    unless is_sysadm
      gcodes = Core.user.groups_and_ancestors.map(&:code)
      self.and {|d|
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", %w(r w a)
          d2.and "digitallibrary_roles.user_id", 'IS', nil
          d2.and "digitallibrary_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", %w(r w a)
          d2.and "digitallibrary_roles.user_id", 'IS', nil
          d2.and "digitallibrary_roles.group_code", gcodes
        }
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", %w(r w a)
          d2.and "digitallibrary_roles.user_code", Core.user.code
        }
      }
    end
    
    self.join "LEFT JOIN digitallibrary_roles ON gwboard_syntheses.title_id = digitallibrary_roles.title_id"
    self.group_by "gwboard_syntheses.id"
  end
  
end
