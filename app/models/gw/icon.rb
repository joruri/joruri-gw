# -*- encoding: utf-8 -*-
class Gw::Icon < Gw::Database
  include System::Model::Base

  include Cms::Model::Base::Content

  belongs_to :gw_icon_groups

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'igid'
       self.and :icon_gid, v
      end
    end if params.size != 0
    return self
  end
end
