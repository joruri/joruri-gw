# encoding: utf-8
class Gw::ScheduleList < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def self.params_set(params)
    ret = ""
    'uid:s_year:s_month'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret.concat "&" unless ret.blank?
        ret.concat "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.get_users(gid = Site.user_group.id)
    join = "inner join system_users_groups on system_users.id = system_users_groups.user_id"
    join.concat " inner join system_users_custom_groups on system_users.id = system_users_custom_groups.user_id"
    cond = "system_users.state='enabled' and system_users_groups.group_id = #{gid}"
    users = System::User.find(:all, :conditions=>cond, :order=>'sort_no, code',
        :joins=>join, :group => 'system_users.id')

    return users
  end

  def self.group_equal(uid = nil)

    return false if uid.blank?

    user = System::User.find(:first, :conditions => "id = #{uid}")
    return false if user.blank?

    return false if user.user_groups.empty? || user.user_groups[0].group.blank?
    group = user.user_groups[0].group

    if Site.user_group.id.to_i == group.id.to_i
      return true
    else
      return false
    end

  end
end
