# encoding: utf-8
class Gwboard::RenewalGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :incoming_group    , :foreign_key => :incoming_group_id    , :class_name => 'System::Group'
  belongs_to :present_group, :foreign_key => :present_group_id, :class_name => 'System::Group'

  attr_accessor :selector

  before_save :set_present_group
  validates_presence_of  :start_date, :incoming_group_code, :incoming_group_name, :present_group_id

  def set_present_group
   if !self.present_group.blank?
      self.present_group_code = self.present_group.code
      self.present_group_name = self.present_group.name
    end
  end
end
