class Gw::Admin::PortalAddCountsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  def count
    @item = Gw::PortalAdd.find(params[:id])
    return http_error(404) unless @item

    @item.logs.create(
      :accessed_at => Time.now,
      :ipaddr => request.ip,
      :user_agent => request.user_agent,
      :referer => request.referer,
      :path => params[:controller],
      :content => 'ad'
    )

    return redirect_to @item.full_url
  end
end
