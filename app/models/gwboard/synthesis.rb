class Gwboard::Synthesis < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  
  def gwbbs_readable_syntheses(date)
    is_sysadm = 
      System::Model::Role.get(1, Site.user.id, 'gwbbs', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id, 'gwbbs', 'admin')
    
    self.and :state, 'public'
    self.and :system_name, 'gwbbs'
    self.and :latest_updated_at, '>=', date
    self.and "sql", "'#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' BETWEEN able_date AND expiry_date"
    unless is_sysadm
      self.and {|d|
        d.or {|d2|
          d2.and "gwbbs_adms.user_id", 0
          d2.and "gwbbs_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwbbs_adms.user_code", Site.user.code
          d2.and "gwbbs_adms.group_code",  Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", ['r','w']
          d2.and "gwbbs_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", ['r','w']
          d2.and "gwbbs_roles.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwbbs_roles.role_code", ['r','w']
          d2.and "gwbbs_roles.user_code", Site.user.code
        }
      }
    end
    
    self.join "LEFT JOIN gwbbs_adms  ON gwboard_syntheses.title_id = gwbbs_adms.title_id"
    self.join "LEFT JOIN gwbbs_roles ON gwboard_syntheses.title_id = gwbbs_roles.title_id"
    self.group_by "gwboard_syntheses.id"
  end
  
  def gwfaq_readable_syntheses(date)
    is_sysadm = 
      System::Model::Role.get(1, Site.user.id, 'gwfaq', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id, 'gwfaq', 'admin')
    
    self.and :state, 'public'
    self.and :system_name , 'gwfaq'
    self.and :latest_updated_at , '>=' , date
    unless is_sysadm
      self.and {|d|
        d.or {|d2|
          d2.and "gwfaq_adms.user_id", 0
          d2.and "gwfaq_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwfaq_adms.user_code", Site.user.code
          d2.and "gwfaq_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", ['r','w']
          d2.and "gwfaq_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", ['r','w']
          d2.and "gwfaq_roles.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwfaq_roles.role_code", ['r','w']
          d2.and "gwfaq_roles.user_code", Site.user.code
        }
      }
    end
    
    self.join "LEFT JOIN gwfaq_adms  ON gwboard_syntheses.title_id = gwfaq_adms.title_id"
    self.join "LEFT JOIN gwfaq_roles ON gwboard_syntheses.title_id = gwfaq_roles.title_id"
    self.group_by 'gwboard_syntheses.id'
  end
  
  def gwqa_readable_syntheses(date)
    is_sysadm = 
      System::Model::Role.get(1, Site.user.id, 'gwqa', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id, 'gwqa', 'admin')
    
    self.and :state, 'public'
    self.and :system_name, 'gwqa'
    self.and :latest_updated_at, '>=' , date
    unless is_sysadm
      self.and {|d|
        d.or {|d2|
          d2.and "gwqa_adms.user_id", 0
          d2.and "gwqa_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwqa_adms.user_code", Site.user.code
          d2.and "gwqa_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwqa_roles.role_code", ['r','w']
          d2.and "gwqa_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "gwqa_roles.role_code", ['r','w']
          d2.and "gwqa_roles.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "gwqa_roles.role_code", ['r','w']
          d2.and "gwqa_roles.user_code", Site.user.code
        }
      }
    end
    
    self.join "LEFT JOIN gwqa_adms  ON gwboard_syntheses.title_id = gwqa_adms.title_id"
    self.join "LEFT JOIN gwqa_roles ON gwboard_syntheses.title_id = gwqa_roles.title_id"
    self.group_by 'gwboard_syntheses.id'
  end
  
  def doclibrary_readable_syntheses(date)
    is_sysadm = 
      System::Model::Role.get(1, Site.user.id, 'doclibrary', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id, 'doclibrary', 'admin')
    
    parent_group_codes = Site.user_group.parent_tree.map{|g| g.code}
    
    self.and :state, 'public'
    self.and :system_name, 'doclibrary'
    self.and :latest_updated_at, '>=', date
    unless is_sysadm
      self.and {|d|
        d.or {|d2|
          d2.and "doclibrary_adms.user_id", 0
          d2.and "doclibrary_adms.group_code", parent_group_codes
        }
        d.or {|d2|
          d2.and "doclibrary_adms.user_code", Site.user.code
          d2.and "doclibrary_adms.group_code", parent_group_codes
        }
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", ['r','w']
          d2.and "doclibrary_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", ['r','w']
          d2.and "doclibrary_roles.group_code", parent_group_codes
        }
        d.or {|d2|
          d2.and "doclibrary_roles.role_code", ['r','w']
          d2.and "doclibrary_roles.user_code", Site.user.code
        }
      }
      self.and {|d|
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 0
        }
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 1
          d2.and "gwboard_syntheses.acl_section_code", parent_group_codes
        }
        d.or {|d2|
          d2.and "gwboard_syntheses.acl_flag", 2
          d2.and "gwboard_syntheses.acl_user_code", Site.user.code
        }
      }
    end
    
    self.join "LEFT JOIN doclibrary_adms  ON gwboard_syntheses.title_id = doclibrary_adms.title_id"
    self.join "LEFT JOIN doclibrary_roles ON gwboard_syntheses.title_id = doclibrary_roles.title_id"
    self.group_by "gwboard_syntheses.title_id"
    self.group_by "gwboard_syntheses.parent_id"
  end
  
  def digitallibrary_readable_syntheses(date)
    is_sysadm = 
      System::Model::Role.get(1, Site.user.id, 'digitallibrary', 'admin') || 
      System::Model::Role.get(2, Site.user_group.id, 'digitallibrary', 'admin')
    
    self.and :state, 'public'
    self.and :system_name, 'digitallibrary'
    self.and :latest_updated_at, '>=', date
    unless is_sysadm
      self.and {|d|
        d.or {|d2|
          d2.and "digitallibrary_adms.user_id", 0
          d2.and "digitallibrary_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "digitallibrary_adms.user_code", Site.user.code
          d2.and "digitallibrary_adms.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", ['r','w']
          d2.and "digitallibrary_roles.group_code", '0'
        }
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", ['r','w']
          d2.and "digitallibrary_roles.group_code", Site.user_group.code
        }
        d.or {|d2|
          d2.and "digitallibrary_roles.role_code", ['r','w']
          d2.and "digitallibrary_roles.user_code", Site.user.code
        }
      }
    end
    
    self.join "LEFT JOIN digitallibrary_adms  ON gwboard_syntheses.title_id = digitallibrary_adms.title_id"
    self.join "LEFT JOIN digitallibrary_roles ON gwboard_syntheses.title_id = digitallibrary_roles.title_id"
    self.group_by "gwboard_syntheses.id"
  end
  
end
