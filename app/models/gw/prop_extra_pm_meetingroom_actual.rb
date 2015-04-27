class Gw::PropExtraPmMeetingroomActual < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop, :foreign_key => :schedule_prop_id, :class_name => 'Gw::ScheduleProp'
  belongs_to :schedule_prop, :foreign_key => :schedule_prop_id, :class_name => 'Gw::ScheduleProp'
  belongs_to :sche, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :meetingroom, :foreign_key => :car_id, :class_name => 'Gw::PropMeetingroom'
  belongs_to :driver_user, :foreign_key => :driver_user_id, :class_name => 'System::User'
  belongs_to :driver_group, :foreign_key => :driver_group_id, :class_name => 'System::Group'

  before_create :set_initial_data
  before_save :set_driver_data
  before_update :return_prop
  after_update :update_time_range

  with_options if: :persisted? do |f|
    f.validates :start_at, :end_at, presence: true
    f.validate do |item|
      if item.start_at && item.end_at && item.start_at > item.end_at
        errors.add(:end_at, "は貸出日時より後の日時にしてください。")
      end
    end
  end

  def prop_state_show
    ps = self.schedule_prop.prop_stat if self.schedule_prop
    I18n.t('enum.gw/prop_extra_pm_common.prop_state')[ps] || ps
  end

  def _meter
    !end_meter.blank? && Gw.int?(end_meter) && !start_meter.blank? && Gw.int?(start_meter) ?
      end_meter - start_meter : ''
  end
  def _price
    _meter.blank? ? '' :
      _meter * Gw::PropExtraPmRentcarUnitPrice.get_unit_price
  end
  def self.is_actual_by_schedule_prop_ids?(schedule_prop_ids)
    schedule_prop_ids_s = schedule_prop_ids.is_a?(String) ? schedule_prop_ids :
      schedule_prop_ids.is_a?(Fixnum) ? schedule_prop_ids.to_s :
      Gw.join(schedule_prop_ids, ',')
    self.where("schedule_prop_id in (#{schedule_prop_ids_s})").to_a.size
  end

  private

  def set_initial_data
    self.summaries_state ||= '2'
    self.bill_state ||= '2'
    self.start_meter ||= 0
    self.end_meter ||= 0

    if schedule
      self.start_at ||= Time.now
      self.to_go ||= schedule.to_go.to_s
      self.title = schedule.title
      self.updated_user ||= "#{schedule.creator_uname} (#{schedule.creator_ucode})"
      self.updated_group ||= "#{schedule.creator_gname}"
      self.created_user ||= "#{schedule.creator_uname} (#{schedule.creator_ucode})"
      self.created_group ||= "#{schedule.creator_gname}"
    end
  end

  def set_driver_data
    if driver_user_id_changed? && driver_user
      self.driver_user_code = driver_user.code
      self.driver_user_name = driver_user.name
    end
    if driver_group_id_changed? && driver_group
      self.driver_group_code = driver_group.code
      self.driver_group_name = driver_group.name
    end
  end

  def return_prop
    if schedule_prop && !schedule_prop.returned?
      schedule_prop.return!
      schedule_prop.save
    end
  end

  def update_time_range
    if self.start_at_changed? || self.end_at_changed?
      if self.start_at && self.end_at && schedule
        if self.end_at < schedule.ed_at
          schedule.update_attributes(
            st_at: self.start_at,
            ed_at: self.end_at
          )
    
          schedule.schedule_props.each do |sp|
            sp.update_attributes(
              st_at: self.start_at,
              ed_at: self.end_at
            )
          end
          schedule.schedule_users.each do |su|
            su.update_attributes(
              st_at: self.start_at,
              ed_at: self.end_at
            )
          end
        end
      end
    end
  end
end
