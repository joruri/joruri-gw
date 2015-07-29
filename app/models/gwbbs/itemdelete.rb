# -*- encoding: utf-8 -*-
class Gwbbs::Itemdelete < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Gwbbs::Model::Systemname

  validates_presence_of :limit_date

  def item_home_path
    return '/gwbbs/itemdeletes'
  end

  def item_path
    return "#{item_home_path}"
  end

  def delete_path
    return "#{item_home_path}/#{self.title_id}/delete"
  end

  def limit_line
    return [['1日', '1.day'],
      ['1ヵ月' , '1.month'],
      ['3ヵ月' , '3.months'],
      ['6ヵ月' , '6.months'],
      ['9ヵ月' , '9.months'],
      ['12ヵ月','12.months'],
      ['15ヵ月','15.months'],
      ['18ヵ月','18.months'],
      ['24ヵ月','24.months']]
  end

  def delete_fix
    return {
      'none'  => 'しない' ,
      '1.day' => '1日' ,
      '3.months'  => '3ヵ月' ,
      '6.months'  => '6ヵ月' ,
      '9.months'  => '9ヵ月' ,
      '12.months'  => '12ヵ月' ,
      '15.months'  => '15ヵ月' ,
      '18.months'  => '18ヵ月' ,
      '24.months'  => '24ヵ月'
    }
  end

end
