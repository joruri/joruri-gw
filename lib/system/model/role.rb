# encoding: utf-8
module System::Model::Role

  def self.get(class_id, uid, table_name, priv_name)
    #ret = self.get_raw(class_id, uid, table_name, priv_name) || 0 == 1 ? true : nil
    ret = (self.get_raw(class_id, uid, table_name, priv_name) || 0) == 1 ? true : nil
    return ret
  end

  def self.get_raw(class_id, uid, table_name, priv_name)
    case class_id
    when 1
      gid_cond = " user_id=#{uid} and (end_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' or end_at is null)"
      gid_wrk = System::UsersGroup.find(:first , :conditions=>gid_cond ,:order=>"job_order")
      if gid_wrk.present? && gid_wrk.group_id.present?
        gid = gid_wrk.group_id
      else
        gid = 0
        return false
      end
    when 2
      gid = uid
    end
    uid = uid.to_i
    gid = gid.to_i
    grp_obj = System::Group.find_by_id(gid)
    gid_parents_raw = grp_obj.parent_tree
    gid_parents = gid_parents_raw.collect{|x| x.id}
    roles = System::Role.new.get table_name, priv_name

    roles.each do |role|
      case role.class_id || 0
      when 0
        return role.priv || 0
      when 1
        next if class_id == 2
        role_uid = role.uid ||''
        return role.priv || 0 if role_uid.to_s == uid.to_s
      when 2
        role_uid = role.uid ||''
        return role.priv || 0 if !gid_parents.index(role_uid.to_i).nil?
      end
    end

#    return 0
    return false
  end

  def self.get_roles(uid = Core.user.id)
    user_group = System::UsersGroup.find(:first, :conditions=>"user_id=#{uid} and end_at is null " , :order=>"job_order")
    gid = nil if user_group.blank?
    group      = user_group.group unless user_group.blank?
    if group.blank?
      gid = nil
    else
      gid = group.id
      parent_gid = group.parent_id
    end

    order = "table_name, priv_name, idx, priv"
    cond = "( class_id = 0 ) or ( class_id = 1 and uid = #{uid} ) or (class_id = 2 and (uid = #{gid} or uid = #{parent_gid}))"
    roles = System::Role.find(:all, :conditions=> cond, :order=> order)

    table_name = nil
    priv_name = nil
    ret = Array.new
    roles.each do |role|
      if role.table_name != table_name || (role.table_name == table_name || role.priv_name != priv_name)
        if role.priv == 1
          ret << [role.table_name, role.priv_name]
        end
      end

      table_name = role.table_name
      priv_name  = role.priv_name
    end

    if roles.empty?
      return nil
    else
      return ret
    end
  end

end
