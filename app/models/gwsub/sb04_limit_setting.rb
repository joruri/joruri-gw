# -*- encoding: utf-8 -*-
class Gwsub::Sb04LimitSetting < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  validates_presence_of :limit
  validates_numericality_of :limit

  before_save :name_save

  def name_save
    self.updated_user  = Core.user.name
    self.updated_group = Core.user_group.name
  end

  def get_type_name
    if self.type_name == 'stafflistview_limit'
      type = "電子職員録"
    elsif self.type_name == 'divideduties_limit'
      type = "電子事務分掌表"
    else
      type = ""
    end
    return type
  end

  def self.get_stafflistview_limit
    item = self.find(:first, :conditions => "type_name = 'stafflistview_limit'")
    if item.blank? || nz(item.limit, 0) == 0
      lim = 30
    else
      lim = item.limit
    end
    return lim
  end

  def self.get_divideduties_limit
    item = self.find(:first, :conditions => "type_name = 'divideduties_limit'")
    if item.blank? || nz(item.limit, 0) == 0
      lim = 30
    else
      lim = item.limit
    end
    return lim
  end

end
