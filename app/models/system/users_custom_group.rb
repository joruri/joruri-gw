# encoding: utf-8
class System::UsersCustomGroup < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config

  self.primary_key = 'rid'

  belongs_to   :user,  :foreign_key => :user_id,  :class_name => 'System::User'
  belongs_to   :custom_group, :foreign_key => :custom_group_id, :class_name => 'System::CustomGroup'

  validates_presence_of :custom_group_id,:user_id

end
