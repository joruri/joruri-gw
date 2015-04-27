class Gw::PropOtherRole < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop_other, :foreign_key => :prop_id, :class_name => 'Gw::PropOther'
  belongs_to :group, :foreign_key => :gid, :class_name => 'System::Group'
  belongs_to :group_history, :foreign_key => :gid, :class_name => 'System::GroupHistory'

  scope :with_auth_and_gids, ->(auth, gids) { where(auth: auth, gid: gids) }

  def auth_admin?
    auth == 'admin'
  end

  def auth_edit?
    auth == 'edit'
  end

  def auth_read?
    auth == 'read'
  end

  def self.admin_group_count( gid = Core.user_group.id )
    p_cond  = "gw_prop_other_roles.gid = #{gid} and gw_prop_other_roles.auth = 'admin' and gw_prop_others.delete_state=0 "
    p_joins = "LEFT JOIN gw_prop_others ON gw_prop_others.id = gw_prop_other_roles.prop_id"
    ret = self.joins(p_joins).where(p_cond).select("gw_prop_other_roles.id")
    return ret.size
  end

  def self.is_admin?( prop_id, gid = Core.user_group.id )
    ret = self.where("prop_id = #{prop_id} and gid = #{gid} and auth = 'admin' ").select("id")
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_edit?( prop_id, gid = Core.user_group.id, parent_id = Core.user_group.parent_id )
    ret = self.where("prop_id = #{prop_id} and gid in (#{gid}, #{parent_id}) and auth = 'edit' ").select("id")
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_read?( prop_id, gid = Core.user_group.id, parent_id = Core.user_group.parent_id )
    ret = self.where("prop_id = #{prop_id} and gid in (#{gid}, #{parent_id}, 0) and auth = 'read' ").select("id")
    if ret.size > 0
      return true
    else
      return false
    end
  end
end
