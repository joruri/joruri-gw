class Gw::Holiday < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_save :set_ed_at

  validates :st_at, :title, presence: true

  def self.find_by_range(d1,d2)
    cond_date = "!('#{d1.strftime('%Y-%m-%d 0:0:0')}' > ed_at" +
      " or '#{d2.strftime('%Y-%m-%d 23:59:59')}' < st_at)"
    return Gw::Holiday.where(cond_date).order('st_at')
  end

  def self.find_by_range_cache(d1,d2)
    c_key = "Gw::Holiday.find_by_range_" + d1.to_s + "_" + d2.to_s
    begin
      value = Rails.cache.read(c_key)
      if value.nil?
        value = self.find_by_range(d1,d2)
        Rails.cache.write(c_key, value, :expires_in => 60)
      else
      end
    rescue
      value = self.find_by_range(d1,d2)
    end
    return value
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  private

  def set_creator
    if Core.user
      self.creator_uid = Core.user.id
      self.creator_ucode = Core.user.code
      self.creator_uname = Core.user.name
    end
    if Core.user_group
      self.creator_gid = Core.user_group.id
      self.creator_gcode = Core.user_group.code
      self.creator_gname = Core.user_group.name
    end
    self.is_public = 1
    self.no_time_id = 1
  end

  def set_ed_at
    self.ed_at = self.st_at
  end
end
