class Gw::PropTypesMessage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop_type, :foreign_key => :type_id, :class_name => 'Gw::PropType'

  validates :sort_no, :body, presence: true

  def state_select
    [['する',1],['しない',2]]
  end

  def state_show
    state_select.each{|a| return a[0] if a[1] == state}
  end
end
