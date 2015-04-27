class Gw::PropRentcar < Gw::PropBase
  include System::Model::Base
  include System::Model::Base::Content

  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :class_name => 'Gw::PropRentcarImage', :dependent => :destroy
  has_many :schedule_props, :class_name => 'Gw::ScheduleProp', :as => :prop
  has_many :schedules, :through => :schedule_props
  has_one  :meter, :foreign_key => :parent_id, :class_name => 'Gw::PropRentcarMeter', :dependent => :destroy
  belongs_to :owner_group, :foreign_key => :gid, :class_name => 'System::Group'

  has_many :prop_other_roles, -> { none }, :foreign_key => :prop_id, :class_name => 'Gw::PropOtherRole'
  belongs_to :prop_type, -> { none }, :foreign_key => :type_id, :class_name => 'Gw::PropType'

  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :meter

  before_save :set_group_name

  validates :car_model, :name, :type_id, :register_no, :exhaust, :year_type, presence: true

  def get_type_class
    "car"
  end

  def display_prop_name
    "#{name}(#{car_model})"
  end

  def display_prop_name_for_select
    name
  end

  def is_admin?(user = Core.user)
    Gw::ScheduleProp.is_pm_admin?
  end

  def reserved_state_select
    [["不可",0 ],["許可",1 ]]
  end

  def reserved_state_show
    reserved_state_select.each{|a| return a[0] if a[1]==reserved_state}
    return nil
  end

  def type_id_select
    I18n.a("enum.gw/prop_rentcar.type_id")
  end

  def type_id_show
    type_id_select.each{|a| return a[0] if a[1]==type_id}
    return nil
  end

  def delete_state_show
    return "済" if delete_state == 1
    return "未"
  end

  private

  def set_group_name
    if gid_changed? && owner_group
      self.gname = owner_group.name
    end
  end
end
