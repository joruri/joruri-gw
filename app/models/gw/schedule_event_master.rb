class Gw::ScheduleEventMaster  < Gw::SectionAdminMaster
  include System::Model::Base
  include System::Model::Base::Content

  default_scope -> { where(func_name: 'gw_event') }

  validates :management_uid, uniqueness: { 
    scope: [:func_name, :state, :management_parent_gid, :management_gid, :management_uid, :range_class_id, :division_parent_gid, :division_gid, :edit_auth],
    message: "と、主管課担当範囲の組み合わせは、既に登録されています。"
  }, if: :state_enabled?

  def state_enabled?
    state == 'enabled'
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

  def self.edit_auth_range_parent_gids(uid = Core.user.id)
    # ユーザーの主幹範囲（所属）を配列で返す
    # 承認権限あり
    uid = nz(uid, Core.user.id)
    items = Gw::SectionAdminMaster.where("func_name = 'gw_event' and state = 'enabled' and edit_auth = 1 and range_class_id = 1 and management_uid=#{uid}").order("division_parent_gid, division_gid")

    parent_groups = []
    items.each do |item|
      group = System::Group.where(:id => item.division_parent_gid).first
      parent_groups  << group if !group.blank?
    end

    parent_groups = parent_groups.sort{|a, b| a.id <=> b.id }

    division_parent_gids  = []    # 配列
    parent_groups.each do |parent_group|
      division_parent_gids  << [parent_group.name, parent_group.id ] if parent_group.level_no == 2
    end
    return division_parent_gids.uniq
  end

  def self.edit_auth_range_gids(uid = Core.user.id)
    # ユーザーの主幹範囲（部局）を配列で返す
    # 承認権限あり
    items = Gw::SectionAdminMaster.where("func_name = 'gw_event' and state = 'enabled' and edit_auth = 1 and range_class_id = 2 and management_uid=#{uid}")
    division_gids = []    # 配列
    items.each do |item|
      group = System::Group.where(:id => item.division_gid).first
      division_gids << [group.name, item.division_gid] if group.present?
    end
    return division_gids.uniq
  end

  def self.is_ev_management_edit_auth?(uid = Core.user.id, gid = nil)
    # 行事予定表 主管課権限の有無
    # 承認権限あり
    if is_ev_management?
      eventmaster = Gw::SectionAdminMaster.where("func_name = 'gw_event' and state = 'enabled' and management_uid=#{uid} and edit_auth = 1").first
      if eventmaster.present?
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.is_ev_management?(uid = Core.user.id)
    # 行事予定表 主管課権限の有無
    uid = nz(uid, Core.user.id)
    eventmaster = Gw::SectionAdminMaster.where("func_name = 'gw_event' and state = 'enabled' and management_uid=#{uid}").first
    if eventmaster.present?
      return true
    else
      return false
    end
  end

  def self.range_gids(uid = Core.user.id, options = {})
    # ユーザーの主幹範囲（部局）を配列で返す
    func_name = 'gw_event'
    section_item = Gw::SectionAdminMaster.where("func_name = '#{func_name}' and state = 'enabled' and range_class_id = 2 and management_uid=#{uid}")
    items = section_item.order("division_parent_gid, division_gid")
    division_gids = []    # 配列
    items.each do |item|
      group = System::Group.find_by_id(item.division_gid)
      division_gids << [group.name, item.division_gid] if group.present? && group.state == "enabled"
    end
    return division_gids
  end

  def self.range_parent_gids(uid = Core.user.id, options = {})
    # ユーザーの主幹範囲（所属）を配列で返す
    func_name = 'gw_event'
    uid = nz(uid, Core.user.id)
    section_item = Gw::SectionAdminMaster.where("func_name = '#{func_name}' and state = 'enabled' and range_class_id = 1 and management_uid=#{uid}")
    items = section_item.order("division_parent_gid, division_gid")

    parent_groups = []
    items.each do |item|
      group = System::Group.where(:id => item.division_parent_gid).first
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
