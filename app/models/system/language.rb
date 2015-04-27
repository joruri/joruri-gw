class System::Language < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :state, :name, :title

  def states
    {'disabled' => '無効', 'enabled' => '有効'}
  end
end
