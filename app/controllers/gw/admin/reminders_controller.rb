class Gw::Admin::RemindersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return error_auth unless Gw::Reminder.is_admin?

    Page.title = "リマインダー表示設定"
  end

  def index
    @items = Gw::Reminder.order(sort_no: :asc).paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    return http_error(404)
  end

  def new
    return http_error(404)
  end

  def create
    return http_error(404)
  end

  def edit
    return http_error(404)
  end

  def update
    return http_error(404)
  end

  def destroy
    return http_error(404)
  end

  def swap
    @item1 = Gw::Reminder.find(params[:id])
    @item2 = Gw::Reminder.find(params[:sid])
    @item1.sort_no, @item2.sort_no = @item2.sort_no, @item1.sort_no
    _update [@item1, @item2]
  end

  def toggle_state
    @item = Gw::Reminder.find(params[:id])
    @item.state = (@item.state == 'enabled' ? 'disabled' : 'enabled')
    _update @item
  end
end
