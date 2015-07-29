# encoding: utf-8
class System::Language < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config

  belongs_to :status,  :foreign_key => :state,      :class_name => 'System::Base::Status'

  validates_presence_of :state, :name, :title

  def states
    {'disabled' => '無効', 'enabled' => '有効'}
  end
end
