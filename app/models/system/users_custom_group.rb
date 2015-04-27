class System::UsersCustomGroup < ActiveRecord::Base
  self.primary_key = :rid
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'
  belongs_to :custom_group, :foreign_key => :custom_group_id, :class_name => 'System::CustomGroup'

  validates :user_id, :sort_no, presence: true
end
