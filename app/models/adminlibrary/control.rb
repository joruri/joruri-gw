class Adminlibrary::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth

  has_many :role, :foreign_key => :title_id, :dependent => :destroy

  def display_first_admin_name
    admingrps = JSON.parse(admingrps_json) rescue nil
    if admingrps && admingrps.first
      return admingrps.first[2]
    end

    adms = JSON.parse(adms_json) rescue nil
    if adms && adms.first
      return adms.first[2]
    end
  end
end
