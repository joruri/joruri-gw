class Gw::DcnApproval < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :r_user, :class_name => 'System::User', :foreign_key => :uid

  def self.is_dev?(user = Core.user)
    user.has_role?('dcn/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin', 'dcn/admin')
  end
end
