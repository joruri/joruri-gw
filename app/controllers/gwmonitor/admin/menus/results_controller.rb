class Gwmonitor::Admin::Menus::ResultsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find(params[:title_id])
    return error_auth unless @title.is_admin?
  end

  def index
    @items = @title.docs.without_preparation
      .tap {|d| break d.where(state: %w(draft editing closed)) if params[:cond] == 'unanswered' }
      .order(state: :asc, section_sort: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @title.docs.find(params[:id])
  end

  def new
    redirect_to url_for(action: :index)
  end

  def edit
    @item = @title.docs.find(params[:id])
  end

  def update
    @item = @title.docs.find(params[:id])
    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.note = "#{@item.note}#{Time.now.strftime("%Y-%m-%d %H:%M")}:#{Core.user.name}によって回答が更新されました。\n"

    _update @item, success_redirect_uri: url_for(action: :index)
  end
end
