class Gw::PropExtraGroupRentcarMaster < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def self.find_uniqueness(_params, action = nil, id = nil, model = Gw::SectionAdminMaster)
    # 重複チェック
    cond_str = "management_parent_gid = ?"
    cond_str += " and func_name = 'gw_props'"
    cond_str += " and state = 'enabled'"
    cond_str += " and management_gid = ?"
    cond_str += " and management_uid = ?"
    cond_str += " and range_class_id = ?"
    cond_str += " and division_parent_gid = ?"
    cond_str += " and division_gid = ?" unless _params[:division_gid].blank?
    cond_str += " and id <> #{id}" if action == :update
    cond = [cond_str, _params[:management_parent_gid],_params[:management_gid],_params[:management_uid],_params[:range_class_id],_params[:division_parent_gid]]
    cond << _params[:division_gid] unless _params[:division_gid].blank?
    _item = model.where(cond).first

    if _item.blank?
      return true
    else
      return false
    end
  end

  def self.params_set(params)
    ret = ""
    'page:sort_keys:s_m_gid:s_d_gid'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.range_gids(uid = Core.user.id, options = {})
    # ユーザーの主幹範囲（部局）を配列で返す
    func_name = 'gw_props'
    items = Gw::SectionAdminMaster.new.find(:all,
      :conditions=>"func_name = '#{func_name}' and state = 'enabled' and range_class_id = 2 and management_uid=#{uid}",
      :order=>"division_parent_gid, division_gid")
    division_gids = []    # 配列
    items.each do |item|
      group = System::Group.find_by_id(item.division_gid)
      if group.present? && group.state == "enabled"
        division_gids << [System::Group.find_by_id(item.division_gid).name, item.division_gid]
      end
    end
    return division_gids
  end

  def self.range_parent_gids(uid = Core.user.id, options = {})
    # ユーザーの主幹範囲（所属）を配列で返す
    func_name = 'gw_props'
    uid = nz(uid, Core.user.id)
    items = Gw::SectionAdminMaster.new.find(:all,
      :conditions=>"func_name = '#{func_name}' and state = 'enabled' and range_class_id = 1 and management_uid=#{uid}",
      :order=>"division_parent_gid, division_gid")

    parent_groups = []
    items.each do |item|
      group = System::Group.find_by_id(item.division_parent_gid)
      parent_groups  << group if group.present? && group.state == "enabled"
    end

    parent_groups = parent_groups.sort{|a, b| a.id <=> b.id }

    division_parent_gids  = []    # 配列
    parent_groups.each do |parent_group|
      division_parent_gids  << [parent_group.name, parent_group.id ] if parent_group.level_no == 2
    end
    return division_parent_gids.uniq
  end
end
