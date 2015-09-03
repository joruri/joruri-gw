module Concerns::Gw::Schedule::Rentcar
  extend ActiveSupport::Concern
  included do
    attr_accessor :tmp_repeat , :repeat_st_date_at, :repeat_ed_date_at, :meetingroom_options
  end

  def set_tmp_id
    self.tmp_id ||= Digest::MD5.new.update(Time.now.to_s).to_s
  end

  def destroy_rentcar_temporaries
    Gw::SchedulePropTemporary.where(:tmp_id=>self.tmp_id).delete_all
  end

  def check_rentcar_duplication(params, mode)
    Gw::ScheduleRepeat.save_with_rels_concerning_repeat(self, params, mode , {:validate => true})
    return false if !self.errors.blank?
    if tmp_owner = System::User.where(:id => params[:item][:owner_uid]).first
      self.owner_uname = tmp_owner.name
      self.owner_gname = tmp_owner.groups[0].try(:name)
    end
    duplication = false
    cond_str = "tmp_id != ? and st_at <= ? and ed_at >= ? and prop_type = ? and prop_id = ? and created_at > ?"
    check_date = Time.now - 5.minutes
    cnt = 0
    tmp_dates = []
    self.meetingroom_options = params[:options]
    rent_item_flg = true
    _props = JSON.parse(params[:item][:schedule_props_json])
    _props.each do |prop|
      case params[:init][:repeat_mode]
      when "1"
        st_at = params[:item][:st_at]
        ed_at = params[:item][:ed_at]
        self.st_at = st_at
        self.ed_at = ed_at
        tmp_dates << {:st_at => st_at, :ed_at => ed_at, :prop_id => prop[1],:genre_name => prop[0]}
        next if prop[0] != "rentcar"
        rent_item_flg = false if Gw::SchedulePropTemporary.where(cond_str,self.tmp_id, ed_at,st_at,check_date, "Gw::PropRentcar", prop[1]).exists?
      when "2"
        self.tmp_repeat = true
        par_item_base, par_item_repeat = Gw::Schedule.separate_repeat_params params
        st_date, ed_date = par_item_repeat[:st_date_at], par_item_repeat[:ed_date_at]
        st_time, ed_time = par_item_repeat[:st_time_at], par_item_repeat[:ed_time_at]
        d_st_date, d_ed_date = Gw.get_parsed_date(st_date), Gw.get_parsed_date(ed_date)
        d_st_time, d_ed_time = Gw.get_parsed_date(st_time), Gw.get_parsed_date(ed_time)
        self.st_at = Gw.datetime_merge_to_day(d_st_date, d_st_time)
        self.ed_at = Gw.datetime_merge_to_day(d_st_date, d_ed_time)
        self.repeat_st_date_at = d_st_date
        self.repeat_ed_date_at = d_ed_date
        dates = (d_st_date.to_date..d_ed_date.to_date).to_a
        dates.each_with_index do |d,i|
          st_at = Gw.datetime_merge_to_day(d, d_st_time)
          ed_at = Gw.datetime_merge_to_day(d, d_ed_time)
          tmp_dates << {:st_at => st_at, :ed_at => ed_at, :prop_id => prop[1],:genre_name => prop[0]}
          rent_item_flg = false if Gw::SchedulePropTemporary.where(cond_str,self.tmp_id, ed_at,st_at,check_date, "Gw::PropRentcar", prop[1]).exists? if prop[0] == "rentcar"
        end
      else
        next
      end
    end
    if rent_item_flg
      destroy_rentcar_temporaries
      tmp_dates.each do |d|
        prop_type = "Gw::Prop#{d[:genre_name].capitalize}"
        Gw::SchedulePropTemporary.create({
         :tmp_id => self.tmp_id,
         :st_at => d[:st_at],
         :ed_at => d[:ed_at],
         :prop_type => prop_type,
         :prop_id => d[:prop_id]
        })
      end
      return true
    else
      self.errors.add :base, "すでに予約済みのデータが存在します。"
      return false
    end
    return false
  end

  def tmp_member_check
    return nil if self.meetingroom_options.blank?
    option_item = self.meetingroom_options
    ret = []
    Gw::ScheduleOption.new.check_select.each{|a| ret << a[0] unless option_item.index(a[1]).blank? }
    return ret.join("、")
  end

  def tmp_props
    Gw::SchedulePropTemporary.where(:tmp_id => self.tmp_id).group("prop_id, prop_type")
  end

  def tmp_schedule_users(params)
    users = []
    sh_users = JSON.parse(params[:item][:schedule_users_json])
    sh_users.each do |sh_user|
      user = System::User.where(:id => sh_user[1], :state => "enabled").first
      users << user if user.present?
    end
    return users
  end

  def tmp_public_groups(params)
    groups = []
    sh_groups = JSON.parse(params[:item][:public_groups_json])
    sh_groups.each do |sh_group|
      group = System::Group.where(:id => sh_group[1], :state => "enabled").first
      groups << group.name if group.present?
    end
    return groups
  end

  def target_attributes
    attributes.except('id','created_at','updated_at')
  end

  def option_attributes
    [
     "form_kind_id",  "todo_st_at_id", "allday_radio_id","todo_ed_at_id","repeat_class_id",
     "repeat_st_date_at", "repeat_ed_date_at", "repeat_st_time_at", "repeat_ed_time_at",
     "repeat_allday_radio_id","schedule_users", "schedule_users_json","schedule_props","schedule_props_json",
     "public_groups","public_groups_json"
    ]
  end

  def init_parameters
    [
      'repeat_mode','st_at','ed_at','repeat_st_date_at','repeat_ed_date_at','repeat_st_time_at','repeat_ed_time_at',
      'schedule_users_json','ucls','uid','uname','prop_cls','prop_id','prop_name','prop_gname','prop_gcode','public_groups_json'
    ]
  end

end
