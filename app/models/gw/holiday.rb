# encoding: utf-8
class Gw::Holiday < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :st_at, :title

  def self.find_by_range(d1,d2)
    cond_date = "!('#{d1.strftime('%Y-%m-%d 0:0:0')}' > ed_at" +
      " or '#{d2.strftime('%Y-%m-%d 23:59:59')}' < st_at)"
    return Gw::Holiday.find(:all, :order => 'st_at', :conditions => cond_date)
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
end
