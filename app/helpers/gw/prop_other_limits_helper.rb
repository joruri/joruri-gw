module Gw::PropOtherLimitsHelper

  def current_count_group_props_each(gid, prop_types)
    counts = []
    total_count = 0
    prop_types.each_with_index do |type, i|
      cond = "gw_prop_other_roles.gid=#{gid} and gw_prop_other_roles.auth='admin' and gw_prop_others.type_id=#{type.id} and gw_prop_others.delete_state=0"
      joins = "left join gw_prop_others on gw_prop_others.id = gw_prop_other_roles.prop_id"
      count = Gw::PropOtherRole.count(:all, :conditions => cond, :joins => joins)
      counts[i] = count
      total_count += count
    end
    counts[prop_types.size] = total_count
    counts
  end

end
