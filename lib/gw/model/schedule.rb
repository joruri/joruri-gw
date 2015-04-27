module Gw::Model::Schedule

  def self.remind
    item = Gw::Schedule.new
    d = Date.today
    if Core.user
      item.and 'class_id', 1
      item.and 'uid', Core.user.id
    end
    items = item.find(:all, :order => 'st_at, ed_at', :joins => :schedule_users,
      :conditions => "gw_schedule_users.class_id = 1 and gw_schedule_users.uid = #{Core.user.id}" +
        " and (#{Gw.date_between_helper :st_at, d, d+2} or #{Gw.date_between_helper :ed_at, d, d+2})")
    ret_ary = []
    items.each do |x|
      date_str = "#{x.st_at.strftime("%m/%d %H:%M")}-" +
        ( x.st_at.strftime("%m/%d") != x.ed_at.strftime("%m/%d") ? x.ed_at.strftime("%m/%d ") : '' ) +
        x.ed_at.strftime("%H:%M")
      title_str = %Q[<a href="/gw/schedules/#{x.id}/show_one">#{x.title}</a>]
      if x.creator_uid != Core.user.id
        uw = System::User.find(:first, :conditions => "id=#{x.creator_uid}")
        title_str.concat " (#{uw.groups[0].name.strip} #{uw.name.strip})"
      end
      ret_ary.push({:date_str => date_str,
        :cls => 'スケジュール',
        :title => title_str})
    end
    return ret_ary
  end

  def self.show_schedule_move_core(ab, my_url, qs)
    ret = ""
    ab.each_with_index do |x, id|
      href = my_url.sub('%d', "#{(x[0]).strftime('%Y%m%d')}").sub('%q', "#{qs}")
      ret.concat ' ' if id != 0
      if x[1] == '前週'
        ret.concat %Q(<a href="#{href}" class="last_week">#{x[1]}</a>)
      elsif x[1] == '前日'
        ret.concat %Q(<a href="#{href}" class="yesterday">#{x[1]}</a>)
      elsif x[1] == '今日'
        ret.concat %Q(<a href="#{href}" class="today">#{x[1]}</a>)
      elsif x[1] == '翌日'
        ret.concat %Q(<a href="#{href}" class="tomorrow">#{x[1]}</a>)
      elsif x[1] == '翌週'
        ret.concat %Q(<a href="#{href}" class="following_week">#{x[1]}</a>)
      elsif x[1] == '前年'
        ret.concat %Q(<a href="#{href}" class="last_year">#{x[1]}</a>)
      elsif x[1] == '前月'
        ret.concat %Q(<a href="#{href}" class="last_month">#{x[1]}</a>)
      elsif x[1] == '今月'
        ret.concat %Q(<a href="#{href}" class="this_month">#{x[1]}</a>)
      elsif x[1] == '翌月'
        ret.concat %Q(<a href="#{href}" class="following_month">#{x[1]}</a>)
      elsif x[1] == '翌年'
        ret.concat %Q(<a href="#{href}" class="following_year">#{x[1]}</a>)
      else
        ret.concat %Q(<a href="#{href}">#{x[1]}</a>)
      end
    end
    return ret
  end

  def self.get_user(uid)
    System::User.where("id=#{uid}").first
  end

  def self.get_users_id_in_group(gid)
    return [] unless System::Group.find(:first, :conditions => "id=#{gid}")
    return System::UsersGroup.joins(:user).where("group_id=#{gid}").order("code").reject{|x| x.user.state != 'enabled'}.collect{|x| x.user_id }
  end

  def self.get_uids(params)
    if params[:gid].present?
      gid = params[:gid]
      if gid =='me'
        gid = Core.user.groups[0].id
      elsif /^\d+$/ !~ gid
        return []
      end
      uids = get_users_id_in_group(gid)
      uids = [Core.user.id] if uids.length == 0
    elsif params[:cgid].present?
      cgid = params[:cgid]
      uids = System::UsersCustomGroup.where("custom_group_id = #{cgid}").order("sort_no").collect{|x| x.user_id }
    else
      uid = params[:uid]
      uid = Core.user.id if uid.nil? || uid == 'me'
      if uid == 'all'
        return System::User.where("state='enabled'").collect{|x| x.id}, nil
      end
      uid = uid.to_i rescue Core.user.id
      uid = Core.user.id if System::User.where("id=#{uid}").length == 0
      uids = [uid]
    end
    return uids
  end

  def self.get_users(params)
    if params[:gid].present?

      gid = params[:gid]
      if gid =='me'
        gid = Core.user.groups[0].id
      elsif /^\d+$/ !~ gid
        return []
      end

      users =  System::User.joins(:user_groups)
        .where(state: 'enabled')
        .where("system_users_groups.group_id = ?", gid)
        .order(sort_no: :asc, code: :asc)
    elsif params[:cgid].present?

      cgid = params[:cgid]
      if /^\d+$/ !~ cgid
        return []
      end

      users = System::User.includes(:users_custom_groups)
        .where(state: 'enabled')
        .where('system_users_custom_groups.custom_group_id = ?', cgid)
        .order('system_users_custom_groups.sort_no')
    elsif params[:uid].present?
      users = System::User.where(id: params[:uid], state: 'enabled')
    else
      users = [Core.user]
    end
    return users
  end

  def self.get_uname(options={})
    case
    when !options[:uid].nil?
      ux = System::User.where("id=#{options[:uid]}").first
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def self.get_gname(options={})
    case
    when !options[:gid].nil?
      ux = System::Group.where("id=#{options[:gid]}").first
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def self.get_group(options={})
    return !options[:gid].nil? ? System::Group.where("id=#{options[:gid]}").first :
      !options[:uid].nil? ? System::User.where("id=#{options[:uid]}").first.groups[0] : nil
  end


  def self.get_group_uid_from_uid(uid)
    user_group = System::UsersGroup.find(:first, :conditions => "user_id=#{uid}") rescue nil
    if user_group.present?
      group = System::User.find(:first, :conditions => "code='#{user_group.group_code}_0'") rescue nil
      return group == nil ? -1 : group.id
    else
      return -1
    end
  end



  def self.meetings_guide_admin?(user = Core.user)
    user.has_role?('meeting_guide/admin')
  end

  def self.meetings_guide_recognizer?(user = Core.user)
    user.has_role?('meeting_guide/recognizer')
  end


  def self.link_to_prop_master(id, genre, options={})
    caption = nz(options[:caption], '設備情報')
    %Q(<a href="/gw/prop_#{genre}s/#{id}">#{caption}</a>)
  end

  def self.get_prop_ids(params)
    return [] if params[:s_genre].nil?
    if params[:prop_id].nil?
      cond = "delete_state = 0 or delete_state is null"
      _mdl = Gw::PropOther.new
      _mdl.find(:all, :conditions=>cond, :order=>'extra_flag, gid, sort_no, name').select{|x|
        x.gid.to_s == Core.user.groups[0].id.to_s
      }.collect{|x| x.id}
    else
      [params[:prop_id]]
    end
  end

  def self.get_prop(prop_id, params)
    _mdl = Gw::PropOther.new
    _mdl.find(:first, :conditions => "id=#{prop_id}")
  end

  def self.get_props(params, is_gw_admin = Gw.is_admin_admin?, options = {})
    case options[:s_genre]
    when "rentcar"
      items = Gw::PropRentcar.where(delete_state: 0).order(sort_no: :asc, id: :asc)
    when "meetingroom"
      items = Gw::PropMeetingroom.where(delete_state: 0).order(sort_no: :asc, id: :asc)
    when "other"
      items = get_other_props(params, is_gw_admin, options)
    else
      items = get_other_props(params, is_gw_admin, options)
    end

    items = items.where(id: params[:prop_id]) if params[:prop_id].present?
    items
  end

  def self.get_other_props(params, is_gw_admin = Gw.is_admin_admin?, options = {})
    props = Gw::PropOther.distinct.joins(:prop_other_roles).includes(:owner_group)
      .where(delete_state: 0)
      .order(type_id: :asc)
      .order('system_groups.sort_no')
      .order(sort_no: :asc, name: :asc)

    unless is_gw_admin
      props = props.merge(Gw::PropOther.with_user_auth(Core.user, %w(read edit)))
    end

    if options[:type_id].present? && options[:type_id] != '0'
      props = props.where(type_id: options[:type_id])
    end

    if options[:s_other_admin_gid].present? && options[:s_other_admin_gid] != 0
      if group = System::Group.find_by(id: options[:s_other_admin_gid])
        gids = group.self_and_enabled_descendants.map(&:id)
        props = props.where("gw_prop_others.id in (select prop_id from gw_prop_other_roles where gw_prop_other_roles.auth = 'admin' and gw_prop_other_roles.gid in (?))", gids)
      end
    end

    props
  end
end
