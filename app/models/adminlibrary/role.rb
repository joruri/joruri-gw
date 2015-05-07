class Adminlibrary::Role < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :control, :foreign_key => :title_id
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'

  scope :with_user_or_groups, ->(user = Core.user, role_code) {
    gcodes = ['0'] + user.groups.map{|g| g.self_and_ancestors.map(&:code)}.flatten
    where(role_code: role_code.split('/'), group_code: gcodes)
  }
end
