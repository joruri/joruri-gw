# -*- encoding: utf-8 -*-
class Gwboard::Synthesetup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content


  def item_home_path
    return '/gwbbs/synthesetup'
  end

  def item_path
    return "#{item_home_path}"
  end

  def update_path
#    return "#{Core.current_node.public_uri}#{self.id}/update"
    return "/gwbbs/synthesetup/#{self.id}"
  end

  def limit_line
    return [['当日分のみ', 'today'],
      ['前日分から' , 'yesterday'],
      ['3日以内' , '3.days'],
      ['4日以内' , '4.days']]
  end

end
