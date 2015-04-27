class Gw::ScheduleOption < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content


  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'

  def check_select
    [["知事", "1"],["副知事","2"],["政策監","3"],["政策監補","4"],["部局長","5"],["出席者名簿を管財課に提出", "6"]]
  end

  def check_show
    return nil if self.body.blank?
    option_item = self.body.split(/,/)
    ret = []
    check_select.each{|a| ret << a[0] unless option_item.index(a[1]).blank? }
    return ret.join("、")
  end

end
