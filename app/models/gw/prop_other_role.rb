# encoding: utf-8
class Gw::PropOtherRole < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop_other,  :foreign_key => :prop_id,     :class_name => 'Gw::PropOther'
  belongs_to :group,       :foreign_key => :gid,         :class_name => 'System::Group'

  def self.get_search_select(pattern, is_gw_admin, gid = Site.user_group.id)

    items = self.find(:all, :conditions=>"auth = '#{pattern}' ",
      :group => "gid", :order => "gid")

    prop_list = [['すべて','']]
    prop_list << ['制限なし','0'] if pattern == "read"
    items.each do |item|
      unless item.group.blank?
        if is_gw_admin || pattern == "admin"
          prop_list << [item.group.name , item.gid]
        elsif  !is_gw_admin && (pattern == "edit" ||  pattern == "read")
          prop_list << [item.group.name , item.gid] if is_admin?(item.prop_id, gid)
        end
      end
    end

    return prop_list
  end

  def self.admin_group_count( gid = Site.user_group.id )
    p_cond  = "gw_prop_other_roles.gid = #{gid} and gw_prop_other_roles.auth = 'admin' and gw_prop_others.delete_state=0 "
    p_joins = "LEFT JOIN gw_prop_others ON gw_prop_others.id = gw_prop_other_roles.prop_id"
    ret = self.find(:all, :select => "gw_prop_other_roles.id",  :conditions=>p_cond ,:joins=>p_joins )
    return ret.size
  end

  def self.is_admin?( prop_id, gid = Site.user_group.id )
    ret = self.find(:all, :select => "id", :conditions=>"prop_id = #{prop_id} and gid = #{gid} and auth = 'admin' " )
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_edit?( prop_id, gid = Site.user_group.id, parent_id = Site.user_group.parent_id )
    ret = self.find(:all, :select => "id", :conditions=>"prop_id = #{prop_id} and gid in (#{gid}, #{parent_id}) and auth = 'edit' " )
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_read?( prop_id, gid = Site.user_group.id, parent_id = Site.user_group.parent_id )
    ret = self.find(:all, :select => "id", :conditions=>"prop_id = #{prop_id} and gid in (#{gid}, #{parent_id}, 0) and auth = 'read' " )
    if ret.size > 0
      return true
    else
      return false
    end
  end

end
