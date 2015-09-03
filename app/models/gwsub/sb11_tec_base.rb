class Gwsub::Sb11TecBase < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  establish_connection :gwsub rescue nil

  def self.is_readable?
    uid = Core.user.id
    sys_admin_role  = Core.user.has_role?("_admin/admin")
    return true if sys_admin_role==true
    tec_admin_role  = Core.user.has_role?("tokushima/admin")
    return true if tec_admin_role==true
    user  = System::User.where(:id => uid).first
    return false if user.blank?
    return false if user.state=='disabled'
    base_data = Gwsub::Sb11TecBase.where(:state => 1, :uid => uid).order("state, uid").first
    return true if base_data.present?
    return false
  end

end
