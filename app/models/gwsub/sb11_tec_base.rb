class Gwsub::Sb11TecBase < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  establish_connection :gwsub rescue nil

  def self.is_readable?
    return true if Core.user.has_role?("_admin/admin")
    return true if Core.user.has_role?("tokushima/admin")
    base_data = Gwsub::Sb11TecBase.where(:state => 1, :uid => Core.user.id).order("state, uid").first
    return true if base_data.present?
    return false
  end

end
