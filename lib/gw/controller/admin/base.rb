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
      begin
        refer_url = URI.parse(items[0].path).path
      rescue URI::InvalidURIError
        refer_url = "/"
      end
      redirect_to refer_url
    end
  end
end
