class Gw::Admin::PortalAddConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @u_role = Gw::PortalAdd.is_admin?
    return error_auth unless @u_role

    Page.title = "広告アイコン管理"

    @pattern_item = Gw::Property::PortalAddDispPattern.first_or_new
    @option_item = Gw::Property::PortalAddDispOption.first_or_new
    @num_item = Gw::Property::PortalAddDispLimit.first_or_new
  end

  def index
    _index [@pattern_item, @option_item, @num_item]
  end

  def edit
  end

  def update
    @pattern_item.options = params[:pattern_item].to_i
    @option_item.options_value = params[:option_item].values
    @num_item.options_value = params[:num_item].values

    _update [@pattern_item, @option_item, @num_item]
  end
end
