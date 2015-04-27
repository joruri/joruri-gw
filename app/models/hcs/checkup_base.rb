class Hcs::CheckupBase < Hcs::CheckupDatabase
  include System::Model::Base
  include System::Model::Base::Content

  def self.checkup_main_uri(checkup_kind)
    opts = [
      [1,'/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/checkup/main'],
      [2,'/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/checkup/partner_main'],
      [3,'/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/checkup/specific_main'],
      [4,'/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/checkup/general_main']
    ]
    str = opts.assoc(checkup_kind)
    str ? str[1] : ""
  end
end
