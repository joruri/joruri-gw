class Questionnaire::Itemdelete < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def limit_line
    [['1日', '1.day'],
      ['1ヵ月' , '1.month'],
      ['3ヵ月' , '3.months'],
      ['6ヵ月' , '6.months'],
      ['9ヵ月' , '9.months'],
      ['12ヵ月','12.months'],
      ['15ヵ月','15.months'],
      ['18ヵ月','18.months'],
      ['24ヵ月','24.months']]
  end

  def limit_line_name
    limit_line.rassoc(limit_date).try(:first).to_s
  end
end
