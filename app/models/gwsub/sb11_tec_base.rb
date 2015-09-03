class Gwsub::Sb11TecBase < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  establish_connection :gwsub rescue nil

  def self.is_readable?
    return true if Core.user.has_role?("_admin/admin", "tokushima/admin") || Gwsub::Sb11TecBase.where(:state => 1, :uid => Core.user.id).exists?
    return false
  end

end
