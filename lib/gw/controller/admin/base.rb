class Gw::Controller::Admin::Base < Sys::Controller::Admin::Base
###  helper Cms::FormHelper
  layout  'admin/gw'
  before_action :check_access_control, unless: -> { request.xhr? }

  def check_access_control
    items = Gw::AccessControl.load_hash[Core.user.id]
    return true if items.blank?

    if items.any? {|item| request.fullpath =~ Regexp.new(Regexp.escape(item.path)) }
      return true
    else
      redirect_to items[0].path
    end
  end
end
