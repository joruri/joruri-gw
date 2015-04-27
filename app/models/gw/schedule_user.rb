class Gw::ScheduleUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule', :touch => true
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

  def user_class?
    class_id == 1
  end

  def group_class?
    class_id == 2
  end

  def class_options
    [['すべて',0],['ユーザー',1],['グループ',2]]
  end

  def class_label
    if schedule && (prop_type = schedule.first_prop_type) && prop_type.restricted?
      prop_type.user_str
    else
      class_options.rassoc(class_id).try(:first)
    end
  end

  def get_object
    case class_id
    when 1 then user
    when 2 then group
    end
  end
end
