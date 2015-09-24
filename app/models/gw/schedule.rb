class Gw::Schedule < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::Gw::Schedule::MeetingGuide
  include Concerns::Gw::Schedule::Rentcar

  validates_presence_of :title, :is_public
  validates_each :st_at do |record, attr, value|
    d_st = Gw.get_parsed_date(record.st_at)
    d_ed = Gw.get_parsed_date(record.ed_at)
    record.errors.add attr, 'と終了日時の前後関係が異常です。' if d_st > d_ed
  end

  has_many :public_roles, :foreign_key => :schedule_id, :class_name => 'Gw::SchedulePublicRole', :dependent => :destroy
  has_many :schedule_users, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleUser', :dependent => :destroy
  has_many :schedule_props, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleProp', :dependent => :destroy
  has_one :schedule_prop, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleProp' # 現在のところ、施設テーブルはスケジュールテーブルと1対1
  has_one :schedule_todo, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleTodo', :dependent => :destroy
  has_one :schedule_events, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleEvent', :dependent => :destroy
  has_one :schedule_option, :foreign_key => :schedule_id, :class_name => 'Gw::ScheduleOption', :dependent=>:destroy
  has_one :prop_meetingroom_actual, :foreign_key => :schedule_id, :class_name => 'Gw::PropExtraPmMeetingroomActual'
  has_one :prop_rentcar_actual, :foreign_key => :schedule_id, :class_name => 'Gw::PropExtraPmRentcarActual'
  belongs_to :repeat, :foreign_key => :schedule_repeat_id, :class_name => 'Gw::ScheduleRepeat'
  belongs_to :parent, :foreign_key => :schedule_parent_id, :class_name => 'Gw::Schedule'
  has_many :child, :foreign_key => :schedule_parent_id, :class_name => 'Gw::Schedule'

  has_many  :schedule_prop_temporaries, :foreign_key => :tmp_id, :primary_key => :tmp_id, :class_name => 'Gw::SchedulePropTemporary'

  belongs_to :creator_user, :foreign_key => :creator_uid, :class_name => 'System::User'
  belongs_to :creator_group, :foreign_key => :creator_gid, :class_name => 'System::Group'

  accepts_nested_attributes_for :schedule_users
  accepts_nested_attributes_for :schedule_props

  scope :without_todo, -> { where(todo: 0) }
  scope :scheduled_between, ->(st_date, ed_date) {
    where(arel_table[:ed_at].gteq(st_date)).where(arel_table[:st_at].lt(ed_date + 1))
  }
  scope :with_participant_uids, ->(uids) {
    joins(:schedule_users).where(Gw::ScheduleUser.arel_table[:uid].in(uids))
  }
  scope :preload_schedule_relations, -> {
    preload(:schedule_todo, :schedule_events, :schedule_users => {:user => :user_groups},
      :public_roles => {:group => :enabled_children},
      :schedule_props => {:prop => :prop_other_roles},
      :child => {:schedule_users => nil, :schedule_props => {:prop => :prop_other_roles}})
  }
  scope :with_participant, ->(user = Core.user) {
    joins(:schedule_users).where(Gw::ScheduleUser.arel_table[:uid].eq(user.id))
  }
  scope :with_creator_or_participant, ->(user = Core.user) {
    joins(:schedule_users).where([
      Gw::ScheduleUser.arel_table[:uid].eq(user.id),
      arel_table[:creator_uid].eq(user.id)
    ].reduce(:or))
  }
  scope :only_main_schedule, ->{
    where([
      self.arel_table[:schedule_parent_id].eq(nil),
      self.arel_table[:id].eq(self.arel_table[:schedule_parent_id])
    ].reduce(:or))
  }

  def title_category_label
    I18n.t('enum.gw/schedule.title_category_id')[title_category_id]
  end

  def title_category_options
    self.class.title_category_options
  end

  def self.title_category_options
    I18n.a('enum.gw/schedule.title_category_id')
  end

  def self.gw_schedules_form_kind_ids
    [['通常', '0'], ['設備予約', '1'], ['Todo', '2']]
  end

  def is_public_label
    self.class.is_public_show(is_public)
  end

  def self.is_public_select
    [['公開（誰でも閲覧可）', 1],['所属内（参加者の所属および公開所属）', 2],['非公開（参加者のみ）',3]]
  end

  def self.is_public_show(is_public)
    is_public_select.rassoc(is_public).try(:first)
  end

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
    repeat_mode = nz(options[:repeat_mode], 1).to_i

    is_pm_admin = options[:is_pm_admin]
    di = par_item.dup
    di[:allday] = nil unless di[:allday]

    di.delete :public_groups
    _public_groups = JSON.parse(par_item[:public_groups_json])
    di.delete :public_groups_json

    di.delete :schedule_users
    _users = JSON.parse(par_item[:schedule_users_json])
    di.delete :schedule_users_json
    kind_id = par_item[:form_kind_id]
    di.delete :form_kind_id

    # 行事予定用
    event_week = di[:event_week]
    event_month = di[:event_month]
    event_word = di[:event_word]
    di.delete :event_week
    di.delete :event_month
    di.delete :event_word

    # Todo用
    todo_st_at_id = di[:todo_st_at_id]
    todo_ed_at_id = di[:todo_ed_at_id]
    todo_repeat_time_id = di[:todo_repeat_time_id]
    di.delete :todo_st_at_id
    di.delete :todo_ed_at_id
    di.delete :todo_repeat_time_id

    di = di.merge ret_updator

    if mode == :create || (mode == :update && !options[:restrict_trans].blank?)
      if di[:creator_uid].blank?
        cu = Core.user
        di[:creator_uid] = cu.id
        di[:creator_ucode] = cu.code
        di[:creator_uname] = cu.name
        cg = cu.groups[0]
        di[:creator_gid] = cg.id
        di[:creator_gcode] = cg.code
        di[:creator_gname] = cg.name
      else
        creator_group = Gw::Model::Schedule.get_group(:gid => di[:creator_gid])
        if creator_group.present?
          di[:creator_gid] = creator_group.id
          di[:creator_gcode] = creator_group.code
          di[:creator_gname] = creator_group.name
        end
      end

      ou = Gw::Model::Schedule.get_user(par_item[:owner_uid]) rescue Core.user
      di[:owner_uid] = ou.id
      di[:owner_ucode] = ou.code
      di[:owner_uname] = ou.name
      og = ou.groups[0]
      di[:owner_gid] = og.id
      di[:owner_gcode] = og.code
      di[:owner_gname] = og.name
    end
    if mode == :update
      ou = Gw::Model::Schedule.get_user(par_item[:owner_uid]) rescue Core.user
      if ou.blank?
        ou = Core.user
      end
      og = ou.groups[0]
      if ou.state != "enabled" || og.blank? || og.class.name != "System::Group"
        ou = Core.user
        og = ou.groups[0]
      end

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

    _props = JSON.parse(par_item[:schedule_props_json])
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
      if options[:option_items]
        opt_item = item.schedule_option || Gw::ScheduleOption.new({:schedule_id => item.id})
        opt_item.body = options[:option_items]
        opt_item.save(:validate => false)
      end


      # 行事予定用
      item_event = []
      if !item.schedule_events.blank?
        item_event = item.schedule_events
      elsif !event_week.blank? || !event_month.blank?
        item_event = Gw::ScheduleEvent.new()
      end
      if !item_event.blank?
        item_event.schedule_id = item.id
        item_event.gid = di[:owner_gid]
        parent_gid = System::Group.find(di[:owner_gid]).parent_id
        item_event.parent_gid = parent_gid
        item_event.uid = di[:owner_uid]
        item_event.st_at = di[:st_at]
        item_event.ed_at = di[:ed_at]
        item_event.title = di[:title]
        item_event.place = di[:place]
        item_event.allday = di[:allday]
        item_event.event_week = event_week
        item_event.event_month = event_month
        item_event.event_word = event_word

        if item_event.week_approval == 1
          item_event.week_approval = item_event.week_approval
        else
          item_event.week_approval = 0
        end
        if item_event.week_open == 1
         item_event.week_open = item_event.week_open
        else
          item_event.week_open = 0
        end
        if item_event.month_approval == 1
         item_event.month_approval = item_event.month_approval
        else
          item_event.month_approval = 0
        end
        if item_event.month_open == 1
         item_event.month_open = item_event.month_open
        else
          item_event.month_open = 0
        end
        return false if !item_event.save
      end
      # 行事予定用 end

      if di[:todo] == '1' # Todoラジオボタンがチェックされている場合
        if !item.schedule_todo.blank?
          item_todo = item.schedule_todo
        else
          item_todo = Gw::ScheduleTodo.new()
        end
        if !item_todo.blank?

          item_todo.schedule_id = item.id
          if mode == :update
            item_todo.updated_at = item.updated_at
          end
          item_todo.st_at = di[:st_at]
          item_todo.ed_at = di[:ed_at]
          item_todo.is_finished = 0
          item_todo.todo_st_at_id = todo_st_at_id
          item_todo.todo_ed_at_id = todo_ed_at_id
          if todo_ed_at_id.to_s == '2'
            item_todo.todo_ed_at_indefinite = 1
          else
            item_todo.todo_ed_at_indefinite = 0
          end
          item_todo.todo_repeat_time_id = todo_repeat_time_id
          return false if !item_todo.save
        end
      else
        if !item.schedule_todo.blank?
          Gw::ScheduleTodo.destroy(item.schedule_todo.id)
        end
      end
      # Todo 登録 end
      if !prop.blank?
        # 管財が存在する場合、schedule_parent_idを記入。
        # 一番最初のidをschedule_parent_idとして格納する。
        # 二重の保存になってしまうので注意。
        if par_item[:schedule_parent_id].blank?
          di[:schedule_parent_id] = item.id
          item.update_attributes(di)
        end

        item_sub = Gw::ScheduleProp.new()
        item_sub.schedule_id = item.id
        item_sub.st_at = item.st_at
        item_sub.ed_at = item.ed_at
        #item_sub.prop_type = "Gw::Prop#{a_props[nz(prop[0],1).to_i - 1][1].capitalize}"
        item_sub.prop_type = "Gw::Prop#{prop[0].capitalize}"
        item_sub.prop_id = prop[1]
        if prop[0] == "meetingroom" && is_pm_admin && mode == :create # 管理者の場合、自動で承認、承認時間を記録する。
          ret_confirm = item_sub.set_extra_data({'confirmed' => 1})
          item_sub.confirmed_at = Time.now
          item_sub.confirmed_uid = Core.user.id
          item_sub.confirmed_gid = Core.user_group.id
        else prop[0] == "meetingroom" && is_pm_admin && mode == :update
          case repeat_mode
          when 1
            delete_prop = delete_props[0]
            if !delete_prop.blank? && delete_prop.prop_type == "Gw::PropMeetingroom" && delete_prop.prop_id == prop[1].to_i
              item_sub.extra_data = delete_prop.extra_data
              item_sub.confirmed_at = delete_prop.confirmed_at
              item_sub.confirmed_uid = delete_prop.confirmed_uid
              item_sub.confirmed_gid = delete_prop.confirmed_gid
            end
          when 2
            delete_props.each do |delete_prop|
              if delete_prop.prop_type == "Gw::PropMeetingroom" &&
                  item.st_at.strftime('%Y-%m-%d').to_date == delete_prop.st_at.strftime('%Y-%m-%d').to_date &&
                  prop[1].to_i == delete_prop.prop_id # 会議室、日付、およびprop_idが同じならば、承認権限を保持。

                item_sub.extra_data = delete_prop.extra_data
                item_sub.confirmed_at = delete_prop.confirmed_at
                item_sub.confirmed_uid = delete_prop.confirmed_uid
                item_sub.confirmed_gid = delete_prop.confirmed_gid
              end
            end
          end
        end

        sc_prop = Gw::ScheduleProp.where(:schedule_id=>item.id).first
        if sc_prop.blank?
          return false if !item_sub.save
        else
        end
      end
      _users.each do |user|
        item_sub = Gw::ScheduleUser.new()
        item_sub.schedule_id = item.id
        item_sub.st_at = item.st_at
        item_sub.ed_at = item.ed_at
        item_sub.class_id = user[0].to_i
        item_sub.uid = user[1]
        return false if !item_sub.save
      end

      # 公開所属
      Gw::SchedulePublicRole.destroy_all("schedule_id=#{item.id}") if mode == :update
      if ( prop.blank? || (!prop.blank? && prop[0] == "other") ) && par_item[:is_public] == '2'
        _public_groups.each do |_public_group|
          item_public_role = Gw::SchedulePublicRole.new()
          item_public_role.schedule_id = item.id
          item_public_role.class_id = 2
          item_public_role.uid = _public_group[1]
          return false if !item_public_role.save
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
    return self.class.where("schedule_repeat_id='#{self.schedule_repeat_id}'").order("st_at, id")
  end

  def  get_parent_items
    # 同じschedule_parent_idを持つ予定を返す。
    if self.schedule_parent_id.blank?
      return Array.new
    else
      return self.class.where("schedule_parent_id='#{self.schedule_parent_id}'").order("st_at, id")
    end
  end


  def  get_repeat_and_parent_items
    # 同じschedule_parent_id、schedule_repeat_idを持つ予定を返す。
    items = Array.new
    items << self # 自分自身を配列に格納

    # schedule_parent_idから繰り返しすべてを取得
    parent_items = self.get_parent_items
    parent_items.each do | parent_item |
      items += parent_item.get_repeat_items
    end

    # schedule_repeat_idから同時施設予約すべてを取得
    repeat_items = self.get_repeat_items
    repeat_items.each do | repeat_item |
      items += repeat_item.get_parent_items
    end

    return items.uniq
  end

  def  get_parent_props_items
    # 同じschedule_repeat_idを持つ予定の、施設一覧を返す。
    parent_items = self.get_parent_items
    if parent_items.blank?
      return Array.new
    else
      props_items = Array.new
      parent_items.each do |parent_item|
        props_items << parent_item.schedule_prop
      end
      return props_items
    end
  end

  def repeat_item_first?
    return true if !self.repeated?

    repeat_id = self.schedule_repeat_id
    sche = Gw::Schedule
    item = sche.where("schedule_repeat_id='#{repeat_id}'").order("st_at").first

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
    item = sche.where("schedule_repeat_id='#{repeat_id}'").order("st_at DESC").first

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
  def schedule_approval?
    # その予定、およびそこに繋がる繰り返し予定が承認されているかどうか確認する。
    # trueは承認、falseは未承認

    event_auth = {:approved => false, :opened => false}

    if self.schedule_events.blank?

    else
      if self.schedule_events.week_approval == 1 || self.schedule_events.month_approval == 1
        event_auth[:approved] = true
      end
      if self.schedule_events.week_open == 1 || self.schedule_events.month_open == 1
        event_auth[:opened] = true
      end
    end

    # 繰り返し
    if !self.schedule_repeat_id.blank?
      repeat_items = self.get_repeat_items
      if !repeat_items.empty?
        repeat_items.each do | repeat_item |
          if !repeat_item.schedule_events.blank?
            if repeat_item.schedule_events.week_approval == 1 || repeat_item.schedule_events.month_approval == 1
              event_auth[:approved] = true
            end
            if repeat_item.schedule_events.week_open == 1 || repeat_item.schedule_events.month_open == 1
              event_auth[:opened] = true
            end
          end
        end
      end
    end

    # 同時予約　schedule_parent_id
    if !self.schedule_parent_id.blank?
      parent_items = self.get_parent_items
      if !parent_items.empty?
        parent_items.each do | parent_item |
          if !parent_item.schedule_events.blank?
            if parent_item.schedule_events.week_approval == 1 || parent_item.schedule_events.month_approval == 1
              event_auth[:approved] = true
            end
            if parent_item.schedule_events.week_open == 1 || parent_item.schedule_events.month_open == 1
              event_auth[:opened] = true
            end
          end
        end
      end
    end
    return event_auth
  end
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      end if params.size != 0
    return self
  end

  def is_actual?
    # 管財実績レコードをもっているかどうか判定
    return nil if self.schedule_props.blank?
    schedule_prop_ids = self.schedule_props.collect{|x| x.id}
    props = Gw::PropExtraPmMeetingroomActual.is_actual_by_schedule_prop_ids?(schedule_prop_ids) +
      Gw::PropExtraPmRentcarActual.is_actual_by_schedule_prop_ids?(schedule_prop_ids)
    return props > 0
  end

  def ret_repeated?
    repeat_id = self.schedule_repeat_id
    item = Gw::ScheduleProp.new
    ret = item.find(:all, :select=>'gw_schedule_props.*, gw_schedules.st_at, gw_schedules.ed_at, gw_schedules.creator_gcode',
      :joins=> "left join gw_schedules on gw_schedule_props.schedule_id = gw_schedules.id",
      :conditions=>"schedule_repeat_id='#{repeat_id}'")

    flg = true
    ret = ret.select{|x|
      flg = false if x.prop_stat > 1
    }
    return flg
  end

  def self.is_schedule_pref_admin?(user = Core.user)
    user.has_role?('schedule_pref/schedule_pref_admin')
  end

  def is_quotable?(user = Core.user)
    is_quotable_participant?(user) && is_quotable_prop?(user)
  end

  def is_public_auth?(is_gw_admin = Gw.is_admin_admin?, options = {})
    # システム管理者であればtrue
    return true if is_gw_admin
    # 作成者であればtrue
    return true if is_creator?(Core.user)

    case is_public
    when 1
      return true
    when 2
      # 参加者、参加者の所属、公開所属(下位の所属を含む)のいずれかであればtrue
      return true if schedule_participants_uids.include?(Core.user.id) ||
        schedule_participants_gids.include?(Core.user_group.id) ||
        schedule_public_roles_gids.include?(Core.user_group.id)
    when 3
      # 参加者であればtrue
      return true if schedule_participants_uids.include?(Core.user.id)
    end

    # 施設管理者であればtrue
    schedule_props.any? {|sp| sp.prop && sp.prop.is_admin?(Core.user) }
  end
  memoize :is_public_auth?

  def self.ret_updator
    items = {}
    uu = Core.user
    items[:updater_uid] = uu.id
    items[:updater_ucode] = uu.code
    items[:updater_uname] = uu.name
    ug = uu.groups[0]
    items[:updater_gid] = ug.id
    items[:updater_gcode] = ug.code
    items[:updater_gname] = ug.name
    return items
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
  def get_prop_items(get_delete_item = false) # 施設一覧を返す
    props = []
    if self.schedule_parent_id.present?
      if self.parent.blank?
        item_parents = Gw::Schedule.where("schedule_parent_id = #{self.schedule_parent_id}").orde("id")
      else
        item_parents = self.parent.child
      end
      item_parents.each do |item_parent|
        item_parent.schedule_props.each do |prop|
          if get_delete_item
            props << prop if !prop.prop.blank?
          else
            props << prop if !prop.prop.blank? && prop.prop.delete_state == 0
          end
        end
      end
    else
      self.schedule_props.each do |prop|
          if get_delete_item
            props << prop if !prop.prop.blank?
          else
            props << prop if !prop.prop.blank? && prop.prop.delete_state == 0
          end
      end
    end
    return props
  end

  def get_propnames
    collect_readable_schedule_props.map {|sp| sp.prop.try(:name) }.join(', ')
  end

  def get_usernames
    users = schedule_users.select(&:user_class?).map(&:user).compact
    groups = schedule_users.select(&:group_class?).map(&:group).compact
    (users + groups).map(&:name).join(', ')
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

    item_event = item.schedule_events
    if !item_event.blank? && ( !item_event.approved?('week') && !item_event.approved?('month') )
      item_event.st_at = st_at
      item_event.ed_at = ed_at
      item_event.save!
    elsif !item_event.blank?
      item_event.updated_at = Time.now
      item_event.save!
    end
  end

  def self.save_with_rels_part(item, params)
    _params = params[:item].dup
    if params[:item][:st_at].present? && params[:item][:ed_at].present?
      st_at, ed_at = Gw.get_parsed_date(params[:item][:st_at]), Gw.get_parsed_date(params[:item][:ed_at])
      d_st_at, d_ed_at = st_at, ed_at
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

    guide_state_old = nz(item.guide_state, '0').to_i
    guide_place_id_old = nz(item.guide_place_id, '0').to_s

    # 会議等案内表示
    guide_state_old = nz(item.guide_state, '0').to_i
    guide_place_id_old = nz(item.guide_place_id, '0').to_s
    schedule_prop = item.schedule_prop
    schedule_event = item.schedule_events
    if (_params[:guide_state] == '1' && guide_state_old == 0) ||
        (schedule_prop.blank? && _params[:guide_state] == '1' && guide_state_old > 0 && guide_place_id_old.to_s != _params[:guide_place_id].to_s)

      if !schedule_prop.blank? && nz(schedule_prop.prop_type == 'Gw::PropMeetingroom')
        meeting_place_item = Gw::MeetingGuidePlace.where(:prop_id => schedule_prop.prop_id).first
        if !meeting_place_item.blank?
          _params[:guide_place] = meeting_place_item.place
        else
          _params[:guide_place] = params[:init][:prop_name]
        end
      elsif !schedule_event.blank? # 会議等案内表示が承認であるとき、場所を入力する。20文字を超えていた場合、丸める。
        event_approved = (schedule_event.week_approval == 1 || schedule_event.month_approval == 1)
        if event_approved
          if _params[:guide_place_id] == '0'
            meeting_place = item.place
            unless meeting_place.blank?
              meeting_place_chars = meeting_place.split(//)
            else
              meeting_place_chars = 0
            end
            if meeting_place_chars.size > 20
              item.errors.add :guide_place_id, 'は、現在の「場所」は20文字を超えているため、「場所に入力」が選択できません。'
            else
              _params[:guide_place] = meeting_place
            end
          else
            meeting_place_item = Gw::MeetingGuidePlace.where(:prop_id => _params[:guide_place_id]).first
            if !meeting_place_item.blank?
              _params[:guide_place] = meeting_place_item.place
            else
              _params[:guide_place] = nil
            end
          end
        end
      end
    elsif _params[:guide_state] == '0' # guide_stateが0の時、会議等案内表示の場所はnilにする。
      _params[:guide_place] = nil
      _params[:guide_ed_at] = '0'
    else
      _params[:guide_place] = item.guide_place # チェックが継続されている場合、会議等案内表示の場所も継続させる。
    end

    if item.errors.size == 0

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
        _users = JSON.parse(params[:item][:schedule_users_json])
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
    if !auth.key?(:is_pm_admin)
      auth[:is_pm_admin] = Gw::ScheduleProp.is_pm_admin?
    end
    if !auth.key?(:is_ev_admin) # 月間・週刊行事予定の主管課。主管課マスタ（schedule_event_masters）で設定。
      auth[:is_ev_admin] = Gw::ScheduleEvent.is_ev_admin?
    end
    if !auth.key?(:is_ev_operator)   # 管理画面の編集権限。月間・週刊行事予定の管理者と主管課（承認あり）。
      auth[:is_ev_operator] = Gw::ScheduleEvent.is_ev_operator?
    end
    if !auth.key?(:is_ev_reader)     # 管理画面の表示権限。月間・週刊行事予定の管理者と主管課。
      auth[:is_ev_reader] = Gw::ScheduleEvent.is_ev_reader?
    end
    return auth
  end

  def schedule_event_existence
    event = self.schedule_events
    if event
      if event.event_week == 1 || event.event_month == 1
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def is_public_closed_auth?(is_gw_admin = Gw.is_admin_admin?, is_pm_admin = Gw::ScheduleProp.is_pm_admin?, options = {})
    return false if is_gw_admin
    uids = []
    gids = []
    schedule_prop = self.schedule_prop

    is_kanzai = 4
    is_other_my = false
    if schedule_prop.present?
      prop = schedule_prop.prop
      if prop.present?
        is_kanzai = schedule_prop.is_kanzai?
        if is_kanzai == 3 && Gw::PropOtherRole.is_admin?(prop.id)
          is_other_my = true
        end
      end
    end

    schedule_users = Gw::ScheduleUser.where("schedule_id = ?", self.id)

    uids = [self.creator_uid]
    schedule_users.each{|x|
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

    self.public_roles.each do |public_role|
      if public_role.class_id == 2
        role_group = public_role.group
        unless role_group.blank?
          if !role_group.blank? && role_group.level_no == 2
            role_group.children.each do |children|
              gids << children.id
            end
          else
            gids << role_group.id
          end
        end
      end
    end

    uids = uids.sort.uniq
    gids = gids.sort.uniq

    common_condition =  ((self.is_public == 2 && self.creator_uid.to_i != Core.user.id && (gids.index(Core.user_group.id).nil? && gids.index(Core.user_group.parent_id).nil?)) ||
        (self.is_public == 3 && uids.index(Core.user.id).nil?))

    if (is_kanzai == 1 || is_kanzai == 2) &&
        common_condition && !is_pm_admin && !is_gw_admin
      return true
    elsif is_kanzai == 3 && !is_other_my && common_condition && !is_gw_admin
      return true
    elsif is_kanzai == 4 && common_condition && !is_gw_admin
      return true
    end

    return false
  end


  def get_edit_delete_level(auth = {})
    auth = Gw::Schedule.ret_auth_hash(auth)
    auth_level = {:edit_level => 100, :delete_level => 100}


    if auth[:is_gw_admin]
      auth_level[:edit_level] = 1
      auth_level[:delete_level] = 1
      return auth_level
    end

    uid = Core.user.id
    gid = Site.user_group.id

    creator = self.creator_uid == uid       # 作成者
    creator_group = self.creator_gid == gid # 作成者所属

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
    prop = self.schedule_prop
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
    uid = Core.user.id
    gid = Core.user_group.id
    if nz(self.todo, 0) == 1 && !self.schedule_todo.blank?
      if nz(self.schedule_todo.is_finished, 0) == 1
        auth_level[:edit_level] = 100
        auth_level[:delete_level] = 100
        return auth_level
      end
    end

    event_flg = self.schedule_event_existence

    event_auth = self.schedule_approval?
    event_state = '承認'
    event_state = '公開' if event_auth[:opened]

    if !prop.blank?
      prop_state = prop.prop_stat || 0
    else
      prop_state = 0
    end

    if event_flg
      is_master_auth = Gw::ScheduleEvent.is_group_event_master_auth?(self.owner_gid)
      if auth[:is_ev_admin] || ( (auth[:is_ev_operator] || auth[:is_ev_reader]) && is_master_auth )
        if !prop.blank? && prop_state > 1
          auth_level[:edit_level] = 100
          auth_level[:delete_level] = 100
        elsif !prop.blank? && prop_state == 1 && !event_auth[:opened]
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
        elsif event_auth[:approved] && !event_auth[:opened]
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
        elsif event_auth[:opened]
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
        elsif creator || participant && !event_auth[:approved]
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 1
        else
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 100
        end
      elsif !event_auth[:approved] && (creator || participant)
        auth_level[:edit_level] = 1
        auth_level[:delete_level] = 1
      elsif (event_auth[:approved] || event_auth[:opened]) && (creator || participant)
        auth_level[:edit_level] = 3
        auth_level[:delete_level] = 100
        auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
      else
        auth_level[:edit_level] = 100
        auth_level[:delete_level] = 100
      end
    end


    if !prop.blank? && (prop.prop_type == "Gw::PropMeetingroom" || prop.prop_type == "Gw::PropRentcar")
      if !event_auth[:approved]

        if auth[:is_pm_admin]
          case prop_state
          when 0, 1
            auth_level[:edit_level] = 1
            auth_level[:delete_level] = 1
          when 2
            auth_level[:edit_level] = 2
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          when 3,4
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          when 5..10, 900
            auth_level[:edit_level] = 4
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          end
        end

        if !auth[:is_pm_admin] && (creator || participant)
          if prop_state == 0
            auth_level[:edit_level] = 1
            auth_level[:delete_level] = 1
          elsif prop_state == 1
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          elsif prop_state == 2 && prop.prop_type == "Gw::PropMeetingroom"
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          elsif prop_state == 3 && prop.prop_type == "Gw::PropMeetingroom"
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          else
            auth_level[:edit_level] = 100
            auth_level[:delete_level] = 100
          end
        end

        if !auth[:is_pm_admin] && (prop.prop_type == "Gw::PropRentcar" && creator_group)
          if prop_state == 0
            auth_level[:edit_level] = 1
            auth_level[:delete_level] = 1
          else
            auth_level[:edit_level] = 100
            auth_level[:delete_level] = 100
          end
        end
      elsif event_auth[:approved] || event_auth[:opened]

        if auth[:is_pm_admin]
          case prop_state
          when 0, 1, 2
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
          when 3, 4, 5..10, 900
            auth_level[:edit_level] = 4
            auth_level[:delete_level] = 100
            auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
          end
        end

        if !auth[:is_pm_admin] && (creator || participant)
          if prop_state == 0
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
          elsif prop_state == 1
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
          else
            auth_level[:edit_level] = 100
            auth_level[:delete_level] = 100
          end
        end

        if !auth[:is_pm_admin] && (prop.prop_type == "Gw::PropRentcar" && creator_group)
          if prop_state == 0
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
          elsif prop_state == 1
            auth_level[:edit_level] = 3
            auth_level[:delete_level] = 100
            auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
          else
            auth_level[:edit_level] = 100
            auth_level[:delete_level] = 100
          end
        end
      else
        if auth[:is_pm_admin]
          auth_level[:edit_level] = 4
          auth_level[:delete_level] = 100
          auth_level[:reason] = "管財施設で#{Gw::ScheduleProp.get_prop_state_str(prop_state)}済のため、編集できる項目を制限しています。"
        end
      end
    end


    if !prop.blank? && prop.prop_type == "Gw::PropOther"
      if !event_auth[:approved]
        if Gw::PropOtherRole.is_admin?(prop.prop.id, gid)
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 1
        end
        if creator || participant
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 1
        end

        if creator_group
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 1
        end
      elsif event_auth[:approved] || event_auth[:opened]
        if Gw::PropOtherRole.is_admin?(prop.prop.id, gid)
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
        end
        if creator || participant
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
        end
      end
    end


    if prop.blank? && !event_flg
      if !event_auth[:approved]
        if creator || participant
          auth_level[:edit_level] = 1
          auth_level[:delete_level] = 1
        end
      elsif event_auth[:approved] || event_auth[:opened]
        if creator || participant
          auth_level[:edit_level] = 3
          auth_level[:delete_level] = 100
          auth_level[:reason] = "週間・月間行事予定表で#{event_state}済のため、編集できる項目を制限しています。"
        end
      end
    end

    return auth_level
  end

  def public_groups_display
    ret = Array.new
    self.public_roles.each do |public_role|
      if public_role.class_id == 2
        if public_role.uid == 0
          ret << "制限なし"
        else
          group = System::GroupHistory.where(:id => public_role.uid).first
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

  def date_between?(date)
    date == self.st_at.to_date || date == self.ed_at.to_date || (self.st_at.to_date < date && date < self.ed_at.to_date)
  end

  def display_time(display_prop, date)
    return display_time_for_todo if self.todo?

    case self.allday
    when 1
      "（時間未定）"
    when 2
      ""
    else
      if display_prop && (sp = schedule_props.detect {|sp| sp.prop == display_prop })
        st_at = sp.st_at
        ed_at = sp.ed_at
      else
        st_at = self.st_at
        ed_at = self.ed_at
      end
      st_at_date = st_at.to_date
      ed_at_date = ed_at.to_date
      if st_at_date == ed_at_date
        "#{I18n.l(st_at, format: :time)}-#{I18n.l(ed_at, format: :time)}"
      elsif date == st_at_date
        "#{I18n.l(st_at, format: :time)}-"
      elsif date == ed_at_date
        "-#{I18n.l(ed_at, format: :time)}"
      else
        ""
      end
    end
  end
  memoize :display_time

  def display_time_for_todo
    str = "[TODO]"
    str += I18n.l(ed_at, format: :time) if schedule_todo && schedule_todo.todo_ed_at_id.to_i == 0
    str
  end

  def display_time_for_mobile(date)
    case self.allday
    when 1 then return "時間未定"
    when 2 then return "終日"
    end
    display_time(nil, date)
  end

  def display_category_class(display_prop = nil)
    if display_prop && (sp = self.schedule_props.detect{|sp| sp.prop == display_prop})
      "category#{sp.prop_stat_category_id || 1}"
    else
      if self.todo?
        "category800"
      else
        "category#{self.title_category_id || 0}"
      end
    end
  end
  memoize :display_category_class

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

  def title_with_category
    cat =
      if todo?
        "【TODO】 "
      elsif title_category_label.present?
        "【#{title_category_label}】 "
      else
        ""
      end
    "#{cat}#{self.title}"
  end

  def todo?
    self.todo == 1
  end

  def todo_flg
     !self.schedule_todo.blank?
  end

  def time_show_str
    time_show = self.time_show
    st_at_s = "#{self.st_at.strftime('%Y-%m-%d')} （#{Gw.weekday(self.st_at.wday)}） #{time_show[:st_at_show]}"
    ed_at_s = "#{self.ed_at.strftime('%Y-%m-%d')} （#{Gw.weekday(self.ed_at.wday)}） #{time_show[:ed_at_show]}"

    if todo_flg == true
      item_todo = self.schedule_todo
      # 開始日時
      if nz(self.schedule_todo.todo_st_at_id, 0 ) == 1
        st_at_s = st_at_base_s
      elsif nz(self.schedule_todo.todo_st_at_id, 0 ) == 2
        st_at_s = '期限なし'
      end
      # 終了日時
      if nz(self.schedule_todo.todo_ed_at_id, 0 ) == 1
        ed_at_s = ed_at_s
      elsif nz(self.schedule_todo.todo_ed_at_id, 0 ) == 2
        ed_at_s = '期限なし'
      end
    end
    return {:st_at_s => st_at_s, :ed_at_s => ed_at_s}
  end

  def first_prop_type
    if sp = self.schedule_props.first
      return sp.prop.prop_type if sp.prop_type == 'Gw::PropOther' && sp.prop
    end
  end

  def participant_title
    if self.todo?
      "担当者"
    else
      if (prop_type = first_prop_type) && prop_type.restricted?
        prop_type.user_str
      else
        "参加者"
      end
    end
  end

  def self.schedule_show_support(schedules)
    # スケジューラー表示用の補助メソッド
    # parent_idを見て、複数の施設を予約したスケジュールを1つにまとめる。
    schedule_parent_ids = Array.new # 同時予約した施設は、先頭の1つのみ表示させるようにする。
    items = Array.new
    schedules.each { |sche|
      # 同時予約した施設は、先頭の1つのみ表示させるようにする。
      if sche.schedule_parent_id.blank?
        items << sche
      else
        if schedule_parent_ids.blank? || schedule_parent_ids.index(sche.schedule_parent_id).blank?
          schedule_parent_ids << sche.schedule_parent_id
          items << sche
        end
      end
    }
    return items
  end

  def guide_state_repeat_approval_check
    # 会議開催案内で、繰り返しの時、会議等案内システムで承認された予定があるかどうかチェックするメソッド。
    # 返り値 存在する：true、存在しない：false
    # 繰り返しがない場合、false
    ret = false
    return ret if self.schedule_repeat_id.blank?
    items = self.get_repeat_items # 同様のschedule_repeat_idを持つアイテムを取得

    items.each do |item|
      ret = true if item.guide_state == 2 # 承認された予定があれば登録
    end
    return ret
  end

  def create_mail_body_parameters

    todo_flg = nz(self.todo, 0) == 1 && self.schedule_todo.present?

    st_at_base_s = self.st_at.strftime('%Y-%m-%d')
    ed_at_base_s = self.ed_at.strftime('%Y-%m-%d')
    if todo_flg
      item_todo = self.schedule_todo
      # 期限
      if nz(item_todo.todo_ed_at_id, 0 ) == 1
        ed_at_s = ed_at_base_s
      elsif nz(item_todo.todo_ed_at_id, 0 ) == 2
        ed_at_s = '期限なし'
      else
        ed_at_s = "#{ed_at_base_s} #{self.ed_at.strftime('%H:%M')}"
      end
      at_s = "期限：#{ed_at_s}"
    else
      # 開始日時、終了日時の文字列
      if self.allday.blank?
        st_at_s = "#{st_at_base_s} #{self.st_at.strftime('%H:%M')}"
        ed_at_s = "#{ed_at_base_s} #{self.ed_at.strftime('%H:%M')}"
      elsif self.allday == 1 # 基本的に1のみ。1、2とで分かれていたバージョンがあるので、分けておく。
        st_at_s = st_at_base_s + " （時間未定）"
        ed_at_s = ed_at_base_s + " （時間未定）"
      elsif self.allday == 2
        st_at_s = st_at_base_s + " （終日）"
        ed_at_s = ed_at_base_s + " （終日）"
      end

      at_s = "開始日時：#{st_at_s}\n終了日時：#{ed_at_s}"
    end

    user_names = self.get_usernames
    return <<URL
下記の通りご案内申し上げます
場所：#{self.place}
#{at_s}
メモ：#{self.memo}
参加者：#{user_names}
URL
  end

  def is_creator?(user = Core.user)
    creator_uid == user.id
  end

  def is_participant?(user = Core.user)
    schedule_users.any? {|su|
      (su.user_class? && su.uid == user.id) || (su.group_class? && su.uid == user.groups.first.try(:gid))
    }
  end

  def is_creator_or_participant?(user = Core.user)
    is_creator?(user) || is_participant?(user)
  end

  def display_title(display_prop = nil, options = {})
    if display_prop && display_prop.pm_related?
      sp = self.schedule_props.detect{|sp| sp.prop == display_prop}
      if sp && sp.necessary_confirm?
        "#{self.owner_gname} [#{sp.confirmed_label}]".html_safe
      else
        self.owner_gname
      end
    elsif options[:action] != 'show' && display_prop && display_prop.prop_type && display_prop.prop_type.restricted?
      user_names = self.schedule_users.map(&:user).compact.map(&:name)
      "#{self.title}<br />#{user_names.map{|name| "<div>#{name}</div>"}.join}".html_safe
    else
      self.title
    end
  end
  memoize :display_title

  def display_tooltip(genre, is_pm_admin)
    title = "件名：#{title_with_category}"
    place = self.place.present? ? "場所： #{self.place}" : ""
    memo = self.memo.present? ? "メモ： #{Gw.br(self.memo)}" : ""
    inquire_to = self.inquire_to.present? ? "連絡先： #{self.inquire_to}" : ""
    public = self.is_public.present? ? "公開範囲： #{is_public_label}" : ""

    user_names = get_usernames
    user_names = user_names.present? ? "参加者： #{user_names}" : ""
    prop_names = get_propnames
    prop_names = prop_names.present? ? "施設： #{prop_names}" : ""

    event_kind = self.schedule_events.present? && self.schedule_events.event_kind_str.present? ?
      "広報： #{self.schedule_events.event_kind_str}" : ""

    tooltips =
      if genre.to_s.in?(%w(meetingroom rentcar))
        part_num_a = []
        part_num_a.push "庁内#{self.participant_nums_inner}人" if self.participant_nums_inner.present?
        part_num_a.push "庁外#{self.participant_nums_outer}人" if self.participant_nums_outer.present?
        part_num_a = ['利用人数：'] + part_num_a if part_num_a.length > 0
        part_num = Gw.join(part_num_a, ' ')

        owner = "利用責任者： #{self.owner_gname} #{self.owner_uname}"
        admin_memo = self.admin_memo.present? ? "管理者メモ： #{self.admin_memo}" : ""

        [
          is_pm_admin ? "" : title,
          place,
          memo,
          is_pm_admin ? owner : "",
          inquire_to,
          is_pm_admin ? "" : public,
          is_pm_admin ? "" : event_kind,
          is_pm_admin ? "" : user_names,
          is_pm_admin ? admin_memo : "",
          is_pm_admin ? part_num : "",
          prop_names
        ]
      else
        [
          title,
          place,
          memo,
          prop_names.present? ? inquire_to : "",
          public,
          event_kind,
          user_names,
          prop_names.present? ? prop_names : ""
        ]
      end

    Gw.simple_strip_html_tags(tooltips.reject(&:blank?).join("<br/>"), exclude_tags: 'br/')
  end
  memoize :display_tooltip

  def readable_schedule_props(user = Core.user)
    s_props = self.schedule_props.select {|sp| sp.prop.present? }
    s_props = s_props.select {|sp| sp.prop.is_admin_or_editor_or_reader?(user) } unless self.is_participant?(user)
    s_props
  end

  def collect_schedule_props
    props = self.schedule_props
    self.child.select{|c| c.id != self.id }.each do |schedule|
      props += schedule.schedule_props
    end
    props
  end

  def collect_readable_schedule_props(user = Core.user)
    props = self.readable_schedule_props
    self.child.select{|c| c.id != self.id }.each do |schedule|
      props += schedule.readable_schedule_props
    end
    props
  end
  memoize :collect_readable_schedule_props

  def exeed_participant_num?(limit = Joruri.config.application['gw.prop_meetingroom_participant_limit'])
    limit && self.participant_nums_inner.to_i + self.participant_nums_outer.to_i >= limit.to_i
  end

  class << self
    def load_system_and_user_settings(user = Core.user)
      system_settings = self.load_system_settings
      user_settings = Gw::Property::ScheduleSetting.where(uid: user.id).first_or_new
      user_settings.schedules.merge(system_settings)
    end

    def load_system_settings
      AppConfig.gw.schedule_system_settings
    end
  end

  private

  def has_pref_admin_participant?
    pref_admin = AppConfig.gw.schedule_pref_admin["pref_admin_code"]
    if pref_admin.present?
      self.schedule_users.any? {|su| su.user && su.user.code == pref_admin }
    else
      false
    end
  end

  def is_quotable_participant?(user = Core.user)
    flag = has_pref_admin_participant?
    !flag || flag && self.class.is_schedule_pref_admin?(user)
  end

  def is_quotable_prop?(user = Core.user)
    self.schedule_props.blank? || self.schedule_props.all? {|sp| sp.prop && sp.prop.is_edit?(user) }
  end

  def schedule_participants_uids
    schedule_users.select(&:user_class?).map(&:uid)
  end

  def schedule_participants_gids
    schedule_users.select(&:group_class?).map(&:uid) +
      schedule_users.select(&:user_class?).map(&:user).compact.map(&:user_groups).flatten.compact.map(&:group_id)
  end

  def schedule_public_roles_gids
    group_roles = public_roles.select(&:group_class?)
    group_roles.map(&:uid) + group_roles.map(&:group).compact.map(&:enabled_descendants).flatten.compact.map(&:id)
  end
end
