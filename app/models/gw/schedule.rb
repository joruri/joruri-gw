# encoding: utf-8
class Gw::Schedule < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :title, :is_public
  validates_each :st_at do |record, attr, value|
    d_st = Gw.get_parsed_date(record.st_at)
    d_ed = Gw.get_parsed_date(record.ed_at)
    record.errors.add attr, 'と終了日時の前後関係が異常です。' if d_st > d_ed
  end
  has_many :schedule_props, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleProp', :dependent=>:destroy
  has_many :schedule_users, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleUser', :dependent=>:destroy
  belongs_to :repeat, :foreign_key => :schedule_repeat_id, :class_name => 'Gw::ScheduleRepeat'
  has_many :public_roles, :foreign_key => :schedule_id, :class_name => 'Gw::SchedulePublicRole', :dependent=>:destroy

  def self.params_set(params)
    _params = Array.new
    [:uid, :gid, :cgid, :s_date, :ref, :prop_id].each do |col|
      if params.key?(col)
        _params << "#{col}=#{params[col]}"
      end
    end
    ret = ""
    if _params.length > 0
      ret = Gw.join(_params, '&')
      ret = '?' + ret
    end
    return ret
  end
  
  def self.get_ref(params)
    if params[:ref] == "prop"
      :prop
    else
      :schedule
    end
  end

  def self.joined_self(options={})
    op = options.dup
    op[:order] = 'st_at, ed_at' if op[:order].blank?
    op[:joins] = 'left join gw_schedule_users on gw_schedules.id = gw_schedule_users.schedule_id'
    op[:select] = 'gw_schedules.*' if op[:select].blank?
    find(:all, op)
  end

  def self.save_with_rels(item, par_item, mode, prop, delete_props = Array.new, options = {})

    di = par_item.dup
    di.delete :public_groups
    _public_groups = JsonParser.new.parse(par_item[:public_groups_json])
    di.delete :public_groups_json

    di.delete :schedule_users
    _users = JsonParser.new.parse(par_item[:schedule_users_json])
    di.delete :schedule_users_json

    di.delete :form_kind_id

    di = di.merge ret_updator

    if mode == :create || (mode == :update && !options[:restrict_trans].blank?)
      if di[:creator_uid].blank?
        cu = Site.user
        di[:creator_uid] = cu.id
        di[:creator_ucode] = cu.code
        di[:creator_uname] = cu.name
        cg = cu.groups[0]
        di[:creator_gid] = cg.id
        di[:creator_gcode] = cg.code
        di[:creator_gname] = cg.name
      else
        creator_group = Gw::Model::Schedule.get_group(:gid => di[:creator_gid])
        di[:creator_gid] = creator_group.id
        di[:creator_gcode] = creator_group.code
        di[:creator_gname] = creator_group.name
      end

      ou = Gw::Model::Schedule.get_user(par_item[:owner_uid]) rescue Site.user
      di[:owner_uid] = ou.id
      di[:owner_ucode] = ou.code
      di[:owner_uname] = ou.name
      og = ou.groups[0]
      di[:owner_gid] = og.id
      di[:owner_gcode] = og.code
      di[:owner_gname] = og.name
    end
    if mode == :update
      ou = Gw::Model::Schedule.get_user(par_item[:owner_uid]) rescue Site.user
      di[:owner_uid] = ou.id
      di[:owner_ucode] = ou.code
      di[:owner_uname] = ou.name
      og = ou.groups[0]
      di[:owner_gid] = og.id
      di[:owner_gcode] = og.code
      di[:owner_gname] = og.name

      if di[:created_at].blank?
        created_at = Time.now
      else
        created_at = di[:created_at].to_datetime
      end
      di[:created_at] = created_at
    end
    if mode == :create
      di.delete :created_at
    end

    _props = JsonParser.new.parse(par_item[:schedule_props_json])
    di.delete :schedule_props
    di.delete :schedule_props_json
    di.delete :allday_radio_id
    di.delete :repeat_allday_radio_id

    di[:st_at] = Gw.date_common(Gw.get_parsed_date(par_item[:st_at])) rescue nil
    di[:ed_at] = di[:st_at].blank? ? nil :
      par_item[:ed_at].blank? ? Gw.date_common(Gw.get_parsed_date(di[:st_at]) + 3600) :
      Gw.date_common(Gw.get_parsed_date(par_item[:ed_at])) rescue nil

    item.st_at = Gw.date_common(Gw.get_parsed_date(par_item[:st_at])) rescue nil
    item.ed_at = Gw.date_common(Gw.get_parsed_date(par_item[:ed_at])) rescue nil

    proc_core = lambda{

      if mode == :update
        return false if !item.update_attributes(di)
        Gw::ScheduleUser.destroy_all("schedule_id=#{item.id}")
        Gw::ScheduleProp.destroy_all("schedule_id=#{item.id}")
        Gw::SchedulePublicRole.destroy_all("schedule_id=#{item.id}")
      else
        return false if !item.update_attributes(di)
      end

      _users.each do |user|
        item_sub = Gw::ScheduleUser.new()
        item_sub.schedule_id = item.id
        item_sub.st_at = item.st_at
        item_sub.ed_at = item.ed_at
        item_sub.class_id = user[0].to_i
        item_sub.uid = user[1]
        return false unless item_sub.save
      end
      _props.each do |prop|
        item_sub = Gw::ScheduleProp.new()
        item_sub.schedule_id = item.id
        item_sub.prop_type = "Gw::PropOther"
        item_sub.prop_id = prop[1]
        return false unless item_sub.save
      end
      if par_item[:is_public] == '2'
        _public_groups.each do |_public_group|
          item_public_role = Gw::SchedulePublicRole.new()
          item_public_role.schedule_id = item.id
          item_public_role.class_id = 2
          item_public_role.uid = _public_group[1]
          return false unless item_public_role.save
        end
      end
      return true
    }

    if !options[:restrict_trans].blank?
      return proc_core.call
    else
      begin
        transaction() do
          raise Gw::ARTransError if !proc_core.call
        end
        return true
      rescue => e
        case e.class.to_s
        when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
        else
          raise e
        end
        return false
      end
    end
  end

  def self.separate_repeat_params(params)
    item_main = HashWithIndifferentAccess.new
    item_repeat = HashWithIndifferentAccess.new
    params[:item].each_key{|k|
      if /^repeat_(.+)/ =~ k.to_s
        item_repeat[$1] = params[:item][k]
      else
        item_main[k] = params[:item][k]
      end
    }
    return [item_main, item_repeat]
  end

  def repeated?
    self.schedule_repeat_id.present?
  end

  def  get_repeat_items
    return Array.new if !self.repeated?
    return self.find(:all, :conditions=>"schedule_repeat_id='#{self.schedule_repeat_id}'", :order=>"st_at, id")
  end

  def repeat_item_first?
    return true if !self.repeated?

    repeat_id = self.schedule_repeat_id
    sche = Gw::Schedule
    item = sche.find(:first, :conditions=>"schedule_repeat_id='#{repeat_id}'", :order=>"st_at")

    if item.id == self.id
      return true
    else
      return false
    end
  end

  def repeat_end_str
    return "" if !self.repeated?

    repeat_id = self.schedule_repeat_id
    sche = Gw::Schedule
    item = sche.find(:first, :conditions=>"schedule_repeat_id='#{repeat_id}'", :order=>"st_at DESC")

    return " ～#{item.ed_at.day.to_s}日"
  end

  def stepped_over?
    st_date = self.st_at.to_date
    ed_data = self.ed_at.to_date

    if st_date + 1 <= ed_data
      return true
    else
      return false
    end
  end

  def stepped_st_date_today?(date = Date.today)
    st_date = self.st_at.to_date
    return st_date == date
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      end if params.size != 0
    return self
  end

  def is_actual?
    return nil
  end

  def self.is_schedule_pref_admin?(uid = Site.user.id)
    System::Model::Role.get(1,uid,'schedule_pref','schedule_pref_admin')
  end

  def is_schedule_pref_admin_users?
    pref_admin = Gw::NameValue.get_cache('yaml', nil, "gw_schedule_pref_admin_default")
    pref_admin_code = nf(pref_admin["pref_admin_code"])
    unless pref_admin_code.blank?
      self.schedule_users.each do |user|
        sys_user = System::User.get(user.uid)
        unless sys_user.blank?
          ucode = nz(System::User.get(user.uid).code, "0")
          if pref_admin_code == ucode
            return true
          end
        end
      end
    end
    return false
  end

  def is_public_auth?(is_gw_admin = Gw.is_admin_admin?, options = {})

    if is_gw_admin
      return true  # ログインユーザーがシステム管理者の時、true
    end

    is_public = nz(self.is_public, 1)

    if is_public == 1
      return true # 公開設定の時、true
    end

    uids = []
    gids = []
    uids = [self.creator_uid]
    self.schedule_users.each{|x|
      if x.class_id == 1
        uids = uids + [x.uid]
        unless x.user.blank?
          x.user.user_groups.each{|z|
            gids = gids + [z.group_id] unless x.user.nil?
          }
        end
      elsif x.class_id == 2
        unless x.group.blank?
          x.group.user_group.each{|z|
            uids = uids + [z.user_id]
            gids = gids + [z.group_id]
          }
        end
      end
    }

    # 公開範囲
    self.public_roles.each do |public_role|
      if public_role.class_id == 2
        role_group = public_role.group
        unless role_group.blank?
          gids << role_group.id
          role_group.enabled_children.each do |child|
            gids << child.id
            child.enabled_children.each do |c|
              gids << c.id
            end
          end
        end
      end
    end

    uids.compact! # nil要素を削除
    gids.compact! # nil要素を削除
    uids = uids.sort.uniq
    gids = gids.sort.uniq

    if is_public == 2
      # 所属内の時、参加者および公開所属、および参加者に存在した場合true
      if self.creator_uid.to_i == Site.user.id || gids.index(Site.user_group.id) || uids.index(Site.user.id)
        return true
      end
    elsif is_public == 3
      if uids.index(Site.user.id)
        return true
      end
    end

    props = self.schedule_props
    props.each do |prop|
      if prop.prop.present?
        if Gw::PropOtherRole.is_admin?(prop.prop.id)
          return true
        end
      end
    end

    return false
  end

  def self.ret_updator
    items = {}
    uu = Site.user
    items[:updater_uid] = uu.id
    items[:updater_ucode] = uu.code
    items[:updater_uname] = uu.name
    ug = uu.groups[0]
    items[:updater_gid] = ug.id
    items[:updater_gcode] = ug.code
    items[:updater_gname] = ug.name
    return items
  end

  def is_schedule_user?(uid = Site.user.id, gid = Site.user_group.id)
    ret = self.schedule_users.select{|x| ( x.class_id == 1 && x.uid == uid ) || ( x.class_id == 2 && x.uid == gid ) }
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def is_prop_type?
    props = self.schedule_props
    return 0 if props.length == 0
    type = 1
    props.each { |prop|
      if prop.prop_type == "Gw::PropOther"
        type = 1 if type <= 1
      end
    }
    return type
  end

  def get_propnames
    schedule_props = Gw::ScheduleProp.find(:all, :conditions=>["schedule_id = ?", self.id])
    _names = Array.new
    names = ""
    len = schedule_props.length
    if len > 0
      is_user = self.is_schedule_user? # 参加者
      schedule_props.each do |schedule_prop|
        get_prop = schedule_prop.prop
        if get_prop.present? && (get_prop.is_admin_or_editor_or_reader? || is_user)
          if get_prop.delete_state != 1
            _names << get_prop.name
          end
        end
      end
    end
    names = Gw.join(_names, '，')
    return names
  end
  
  def get_usernames
    _names = Array.new
    names = ""
    schedule_users = Gw::ScheduleUser.find(:all, :conditions=>["schedule_id = ?", self.id])
    len = schedule_users.length
    if len > 0
      schedule_users.each do |schedule_user|
        begin
          case schedule_user.class_id
          when 0
          when 1
            user = schedule_user.user
            _names << user.name if user.present? && user.state == 'enabled'
          when 2
            group = schedule_user.group
            _names << group.name if group.present? && group.state == 'enabled'
          end
        rescue
        end
      end
    end
    names = Gw.join(_names, '，')
    return names
  end

  def self.schedule_linked_time_save(item, st_at, ed_at)

    item.schedule_props.each do |item_prop|
      item_prop.st_at = st_at
      item_prop.ed_at = ed_at
      item_prop.save!
    end

    item.schedule_users.each do |item_user|
      item_user.st_at = st_at
      item_user.ed_at = ed_at
      item_user.save!
    end

  end

  def self.save_with_rels_part(item, params)

    _params = params[:item].dup
    if params[:item][:st_at].present?
      st_at, ed_at = Gw.get_parsed_date(params[:item][:st_at]), Gw.get_parsed_date(params[:item][:ed_at])
      d_st_at, d_ed_at = Gw.get_parsed_date(st_at), Gw.get_parsed_date(ed_at)
      item.errors.add :st_at, 'と終了日時の前後関係が不正です。'  if st_at > ed_at
      item.errors.add :st_at, 'と終了日時は１年以内でなければいけません。' if (d_ed_at - d_st_at) > 86400 * 365
    end

    if !params[:item][:allday_radio_id].blank?
      if params[:init][:repeat_mode] == "1"
        _params[:allday] = params[:item][:allday_radio_id]
      elsif params[:init][:repeat_mode] == "2"
        _params[:allday] = params[:item][:repeat_allday_radio_id]
      end
    else
      _params[:allday] = nil
    end

    if item.errors.length == 0

      if !params[:item][:st_at].blank?
        _params[:st_at] = st_at.strftime("%Y-%m-%d %H:%M:%S")
        _params[:ed_at] = ed_at.strftime("%Y-%m-%d %H:%M:%S")
        schedule_linked_time_save(item, st_at, ed_at)
      end

      if !params[:item][:allday_radio_id].blank?
        _params[:allday] = _params[:allday_radio_id]
      end

      _params = _params.merge ret_updator
      _params[:updated_at] = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      _params[:admin_memo] = params[:item][:admin_memo]

      if !params[:item][:schedule_users_json].blank?
        _users = JsonParser.new.parse(params[:item][:schedule_users_json])
        Gw::ScheduleUser.destroy_all("schedule_id=#{item.id}")
        _users.each do |user|
          item_sub = Gw::ScheduleUser.new()
          item_sub.schedule_id = item.id
          item_sub.st_at = st_at
          item_sub.ed_at = ed_at
          item_sub.class_id = user[0].to_i
          item_sub.uid = user[1]
          return false if !item_sub.save
        end
      end

      _params = _params.reject{|k,v|!%w(ed_at(1i) ed_at(2i) ed_at(3i) ed_at(4i) ed_at(5i) st_at(1i) st_at(2i) st_at(3i) st_at(4i) st_at(5i) schedule_users_json schedule_users allday_radio_id allday_radio_id form_kind_id).index(k).nil?}

      item.update_attributes(_params)
      return true

    else
      return false
    end

  end

  def self.ret_auth_hash(auth = {})
    if !auth.key?(:is_gw_admin)
      auth[:is_gw_admin] = Gw.is_admin_admin?
    end
    return auth
  end

  def get_edit_delete_level(auth = {})
    # auth_level[:edit_level]
    #    1：編集可能
    #    2：開始日時、終了日時、終日、管理者メモのみ編集可能
    #    3：参加者を編集可能
    #    4：管理者メモのみ編集可能
    #    100：編集不可
    # auth_level[:delete_level]
    #    1：削除可能
    #    100：削除不可

    auth = Gw::Schedule.ret_auth_hash(auth)
    auth_level = {:edit_level => 100, :delete_level => 100}

    if auth[:is_gw_admin]
      auth_level[:edit_level] = 1
      auth_level[:delete_level] = 1
      return auth_level
    end

    uid = Site.user.id

    if self.creator_uid == uid
      creator = true
    else
      creator = false
    end

    schedule_uids = self.schedule_users.select{|x|x.class_id==1}.collect{|x| x.uid}
    participant = schedule_uids.index(uid).present?

    if participant # 参加者
      auth_level[:edit_level] = 1
      auth_level[:delete_level] = 1
    end

    if creator # 作成者
      auth_level[:edit_level] = 1
      auth_level[:delete_level] = 1
    end

    # prop
    props = self.schedule_props

    prop_admin = true
    if props.length == 0
      prop_admin = false
    end
    props.each do |prop|
      unless Gw::PropOtherRole.is_admin?(prop.prop.id)
        prop_admin = false
      end
    end
    if prop_admin
      auth_level[:edit_level] = 1
      auth_level[:delete_level] = 1
    end

    return auth_level
  end

  def self.schedule_tabbox_struct(tab_captions, selected_tab_idx = nil, radio = nil, options = {})

    tab_current_cls_s = ' ' + Gw.trim(nz(options[:tab_current_cls_s], 'current'))
    id_prefix = Gw.trim(nz(options[:id_prefix], nz(options[:name_prefix], '')))
    id_prefix = "[#{id_prefix}]" if !id_prefix.blank?
    
    tabs = <<-"EOL"
<div class="tabBox">
<table class="tabtable">
<tbody>
<tr>
<td id="spaceLeft" class="spaceLeft"></td>
EOL
    tab_idx = 0
    tab_captions.each_with_index{|x, idx|
      tab_idx += 1
      _name = "tabBox#{id_prefix}[#{tab_idx}]"
      _id = Gw.idize(_name)
      tabs.concat %Q(<td class="tab#{selected_tab_idx - 1 == idx ? tab_current_cls_s : nil}" id="#{_id}">#{x}</td>) +
        (tab_captions.length - 1 == idx ? '' : '<td id="spaceCenter" class="spaceCenter"></td>')
    }
    tabs.concat <<-"EOL"
<td id="spaceRight" class="spaceRight">#{radio}</td>
</tr>
</tbody>
</table>
</div><!--tabBox-->
EOL
    return tabs
  end

  def public_groups_display
    ret = Array.new
    self.public_roles.each do |public_role|
      if public_role.class_id == 2
        if public_role.uid == 0
          ret << "制限なし"
        else
          group = System::GroupHistory.find_by_id(public_role.uid)
          if !group.blank?
            if group.state == "disabled"
              ret << "<span class=\"required\">#{group.name}</span>"
            else
              ret << [group.name]
            end
          else
            ret << "<span class=\"required\">削除所属 gid=#{public_role.uid}</span>"
          end
        end
      end
    end
    return ret
  end
  
  def self.repeat_weekday_select
    items = [['日曜日', 0], ['月曜日', 1], ['火曜日', 2], ['水曜日', 3], ['木曜日', 4], ['金曜日', 5], ['土曜日', 6]]
    return items
  end
  def self.repeat_weekday_show
    is_public_items = [['公開（誰でも閲覧可）', 1],['所属内（参加者の所属および公開所属）', 2],['非公開（参加者のみ）',3]]
    return is_public_items
  end

  def self.is_public_select
    is_public_items = [['公開（誰でも閲覧可）', 1],['所属内（参加者の所属および公開所属）', 2],['非公開（参加者のみ）',3]]
    return is_public_items
  end

  def self.is_public_show(is_public)
    is_public_items = [[1,'公開（誰でも閲覧可）'],[2,'所属内（参加者の所属および公開所属）'],[3,'非公開（参加者のみ）']]
    show = is_public_items.assoc(is_public)
    if show.blank?
      return nil
    else
      return show[1]
    end
  end

  def time_show
    if nz(self.allday, 0) == 0
      st_at_s = self.st_at.strftime('%H:%M')
      ed_at_s = self.ed_at.strftime('%H:%M')
    elsif self.allday == 1
      st_at_s = "時間未定"
      ed_at_s = "時間未定"
    elsif self.allday == 2
      st_at_s = "終日"
      ed_at_s = "終日"
    end
    return {:st_at_show => st_at_s, :ed_at_show => ed_at_s}
  end
  
  def date_between(date)
    flg = date == self.st_at.to_date || date == self.ed_at.to_date || (self.st_at.to_date < date && date < self.ed_at.to_date)
    return flg
  end
  
  def show_time(date, view = :pc)
    # view
    # :pc、:smart_phone、:mobile
    case self.allday
    when 1
      if view == :pc
        return "（時間未定）"
      else
        return "時間未定"
      end
    when 2
      if view == :pc
        return ""
      else
        return "終日"
      end
    else
      date_array = Gw.date_array(self.st_at, self.ed_at)
      case date_array.length
      when 1
        return "#{Gw.time_str(self.st_at)}-#{Gw.time_str(self.ed_at)}"
      else
        if date == self.st_at.to_date
          return "#{Gw.time_str(self.st_at)}-"
        elsif date == self.ed_at.to_date
          return "-#{Gw.time_str(self.ed_at)}"
        else
          return ""
        end
      end
    end
  end
  
  def show_day_date_range(st_date)
    if self.ed_at.to_date > st_date
      ed_at = 23.5
    else
      ed_at = self.ed_at.hour
      ed_at += 0.5 if self.ed_at.min > 30
      ed_at -= 0.5 if self.ed_at.min == 0 && ed_at != 0 && self.st_at != self.ed_at
    end
    if self.st_at.to_date < st_date
      st_at = 0
    else
      st_at =  self.st_at.hour
      st_at += 0.5 if  self.st_at.min >= 30
    end
    
    return st_at, ed_at
  end
  
  def get_category_class
    return "category#{nz(self.title_category_id, 0)}"
  end
end
