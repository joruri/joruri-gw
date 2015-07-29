# -*- encoding: utf-8 -*-
###############################################################################
# アンケート　記事削除管理テーブル
###############################################################################
class Questionnaire::Itemdelete < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content

#  validates_presence_of :limit_date

  #
  def item_home_path
    return '/questionnaire/itemdeletes'
  end
  def item_path
    return "#{item_home_path}"
  end
  def edit_path
    return '/questionnaire/itemdeletes/0/edit'
  end
  def update_path
    return '/questionnaire/itemdeletes/0'
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

  #
  def limit_line_name
    case self.limit_date
    when '1.day'
      '1日'
    when '1.month'
      '1ヵ月'
    when '3.months'
      '3ヵ月'
    when '6.months'
      '6ヵ月'
    when '9.months'
      '9ヵ月'
    when '12.months'
      '12ヵ月'
    when '15.months'
      '15ヵ月'
    when '18.months'
      '18ヵ月'
    when '24.months'
      '24ヵ月'
    else
      ''
    end
  end
end
