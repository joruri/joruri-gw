# encoding: utf-8
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
    System::User.find(:first, :conditions => "id=#{uid}")
  end

  def self.get_users_id_in_group(gid)
    return [] unless System::Group.find(:first, :conditions => "id=#{gid}")
    return System::UsersGroup.find(:all, :conditions => "group_id=#{gid}",
      :joins => :user,
      :order => "code").reject{|x| x.user.state != 'enabled'}.collect{|x| x.user_id }
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
      uids = System::UsersCustomGroup.find(:all,
        :conditions => "custom_group_id = #{cgid}",
        :order => "sort_no"
        ).collect{|x| x.user_id }
    else
      uid = params[:uid]
      uid = Core.user.id if uid.nil? || uid == 'me'
      if uid == 'all'
        return System::User.find(:all, :conditions => "state='enabled'").collect{|x| x.id}, nil
      end
      uid = uid.to_i rescue Core.user.id
      uid = Core.user.id if System::User.find(:all, :conditions => "id=#{uid}").length == 0
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

      users =  System::User.find(:all,
        :conditions => "system_users_groups.group_id=#{gid} AND system_users.state = 'enabled'",
        :joins => :user_groups,
        :order => "system_users.sort_no, system_users.code")

    elsif params[:cgid].present?

      cgid = params[:cgid]
      if /^\d+$/ !~ cgid
        return []
      end

      u = System::User.new
      u.class.has_many :user_custom_groups_temp, :foreign_key => :user_id,
      :class_name => 'System::UsersCustomGroup', :dependent=>:destroy,
      :conditions => " custom_group_id = #{params[:cgid]}"
      users = u.find(:all,
        :conditions => "system_users.state = 'enabled' AND system_users_custom_groups.custom_group_id = #{cgid}",
        :order => "system_users_custom_groups.sort_no" ,
        :joins => :user_custom_groups_temp,
        :include => :user_custom_groups_temp
        )

    elsif params[:uid].present?
      users = System::User.find(:all, :conditions => "id = #{params[:uid]} and state = 'enabled'")
    else
      users = [Core.user]
    end
    return users
  end

  def self.get_uname(options={})
    case
    when !options[:uid].nil?
      ux = System::User.find(:first, :conditions=>"id=#{options[:uid]}")
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def self.get_gname(options={})
    case
    when !options[:gid].nil?
      ux = System::Group.find(:first, :conditions=>"id=#{options[:gid]}")
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name))
    else
      return ''
    end
  end
  def self.get_group(options={})
    return !options[:gid].nil? ? System::Group.find(:first, :conditions=>"id=#{options[:gid]}") :
      !options[:uid].nil? ? System::User.find(:first, :conditions=>"id=#{options[:uid]}").groups[0] : nil
  end

  def self.link_to_prop_master(id, genre, options={})
    caption = nz(options[:caption], '設備情報')
    %Q(<a href="/gw/prop_#{genre}s/#{id}">#{caption}</a>)
  end

  def self.get_prop_ids(params)
    return [] if params[:s_genre].nil?
    if params[:prop_id].nil?
      cond = "delete_state = 0 or delete_state is null"
      _mdl = Gw::PropOther
      _mdl.find(:all, :conditions=>cond, :order=>'extra_flag, gid, sort_no, name').select{|x|
        x.gid.to_s == Core.user.groups[0].id.to_s
      }.collect{|x| x.id}
    else
      [params[:prop_id]]
    end
  end

  def self.get_prop(prop_id, params)
    _mdl = Gw::PropOther
    _mdl.find(:first, :conditions => "id=#{prop_id}")
  end

  def self.get_props(params, is_gw_admin = Gw.is_admin_admin?, options = {})

    s_other_admin_gid = options[:s_other_admin_gid].to_i
    group = Core.user.groups[0]
    _mdl = Gw::PropOther
    cond = ""

    cond.concat " delete_state = 0"
    cond_type = ""

    if is_gw_admin
      if options[:type_id].blank?
        cond_type = ""
      elsif params[:type_id] == '0'
      else
        cond_type = " and type_id = #{options[:type_id]}"
      end
    else
      cond_type = " and type_id = #{options[:type_id]}" if options[:type_id].present? && options[:type_id] != '0'
    end
    cond_other = "delete_state = 0 and (auth = 'read' or auth = 'edit') and ((gw_prop_other_roles.gid = #{group.id} or gw_prop_other_roles.gid = #{group.parent_id}) or (gw_prop_other_roles.gid = 0))"
    cond_other.concat cond_type

    cond_other_admin = ""
    if s_other_admin_gid != 0 # 絞り込み
      s_other_admin_group = System::GroupHistory.find_by_id(s_other_admin_gid)
      s_other_admin_group
      cond_other_admin = "auth = 'admin'"
      if s_other_admin_group.level_no == 2 # 部局
        gids = Array.new
        gids << s_other_admin_gid
        parent_groups = System::GroupHistory.new.find(:all, :select => "id", :conditions => ['parent_id = ?', s_other_admin_gid])
        parent_groups.each do |parent_group|
          gids << parent_group.id
        end
        search_group_ids = Gw.join([gids], ',')
        cond_other_admin.concat " and gw_prop_other_roles.gid in (#{search_group_ids})"
      else # 所属
        cond_other_admin.concat " and gw_prop_other_roles.gid = #{s_other_admin_group.id}"
      end

      if is_gw_admin
        cond_other_admin = " and #{cond_other_admin}"
      else
        cond_other_admin = " and gw_prop_others.id in (select `prop_id` from `gw_prop_other_roles` where #{cond_other_admin})"
      end
    end

    if params[:prop_id].blank?
      if is_gw_admin
        other_items = _mdl.find(:all, :conditions=>cond + cond_type + cond_other_admin, :order=>'type_id, gid, coalesce(sort_no, 0), name',
          :joins => :prop_other_roles, :group => "gw_prop_others.id")
      else
        other_items = _mdl.find(:all, :conditions=>cond_other + cond_other_admin, :order=>'type_id, gid, coalesce(sort_no, 0), name, gw_prop_others.gid',
          :joins => :prop_other_roles, :group => "gw_prop_others.id")

      end

      parent_groups = Gw::PropOther.get_parent_groups

      _items = other_items.sort{|a, b|
          ag = System::GroupHistory.find_by_id(a.get_admin_first_id(parent_groups))
          bg = System::GroupHistory.find_by_id(b.get_admin_first_id(parent_groups))
          flg = (!ag.blank? && !bg.blank?) ? ag.sort_no <=> bg.sort_no : 0
          (a.type_id <=> b.type_id).nonzero? or (flg).nonzero? or a.sort_no <=> b.sort_no
      }
      return _items
    else
      _mdl.find(:all, :conditions=>["id = ? and delete_state = 0",params[:prop_id]] )
    end
  end

  def self.get_settings(_key, options={})
    key = _key.to_s
    options[:nodefault] = 1 if !%w(ssos).index(key).nil?
    ret = {}

    if options[:nodefault].nil?
      ret.merge! Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")
    end

    ind = Gw::Model::UserProperty.get(key.singularize, options)
    if !ind.blank? && !ind[key].blank?
      if key == 'portals'
        ret = ind[key]
        remove_obsolete_rss(ret)
      else
        ret.merge! ind[key]
      end
    end
    return HashWithIndifferentAccess.new(ret)
  end

  def self.remove_obsolete_rss(hh)
    hh.reject! do |item|
      !item[1]['piece_name'].blank? && item[1]['piece_name'].index('piece/gw-rssreader') == 0 if item.length >= 2
    end
  end

  def self.get_ind_portal_add_cands_all
    sql = Condition.new
    sql.and :state, 'public'
    sql.and :view_hide , 1
    sql.and "sql", "gwbbs_roles.role_code = 'r'"
    sql.and "sql", "gwbbs_roles.group_code = '0'"

    join = "INNER JOIN gwbbs_roles ON gwbbs_controls.id = gwbbs_roles.title_id"
    items = Gwbbs::Control.find(:all, :joins=>join, :conditions=>sql.where,:order => 'sort_no, updated_at DESC', :group => 'gwbbs_controls.id')
    add_cands = []

    add_cands += items.sort{|a,b|a.sort_no<=>b.sort_no}.collect{|x|["#{x.id}", "掲示板/#{x.title}", 'gwbbs']}
    add_cands += [["3", "新着情報", 'gwbbs']]
    add_cands
  end

  def self.cut_strng(strng, cut_num, strt_pnt = 0)
    if cut_num == nil || cut_num == 0 then
      return ''
    else
      end_pnt = strt_pnt + cut_num
    end
    if end_pnt >= jp_chr_num(strng) then
      end_pnt = jp_chr_num(strng)-1
    end
    if strt_pnt > end_pnt then
      return ''
    end
    strng_chrs = Array.new
    strng_chrs = strng.split(//u)
    cut_strng = ''
    strt_pnt.upto(end_pnt) do |x|
      cut_strng.concat strng_chrs[x]
    end
    return cut_strng
  end
end
