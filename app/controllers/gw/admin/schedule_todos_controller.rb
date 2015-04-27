class Gw::Admin::ScheduleTodosController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/todo"

  def pre_dispatch
    Page.title = "ToDo"
    params[:limit] = 10 if request.mobile?
    @css = %w(/_common/themes/gw/css/schedule.css /_common/themes/gw/css/todo.css)
    @sp_mode = :todo
    @myuid = Core.user.id
    @mygid = Core.user_group.id
    x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
    if !x.blank?
      @cgid = x.id
    end
    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)
  end

  def url_options
    super.merge(params.slice(:s_finished, :sort_keys).symbolize_keys)
  end

  def index
    @items = Gw::ScheduleTodo.distinct.search_with_params(params).index_order_with_params(params)
      .joins(:schedule).merge(Gw::Schedule.with_creator_or_participant(Core.user))
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:schedule)
  end

  def show
    @item = Gw::ScheduleTodo.find(params[:id])
  end

  def finish
    @item = Gw::ScheduleTodo.find(params[:id])
    return http_error(404) if @item.schedule.todo != 1
    return error_auth if !Gw.is_admin_admin? && !@item.schedule.is_creator_or_participant?(Core.user)

    finish = !@item.is_finished?

    @item.attributes = {
      finished_at: Time.now,
      finished_uid: Core.user.id,
      finished_gid: Core.user_group.id,
      is_finished: finish ? 1 : 0
    }

    if params.key?(:link) && params[:link] == 'show_one'
      redirect = "/gw/schedules/#{@item.schedule.id}/show_one"
    else
      redirect = {action: :index}
    end

    _update @item, success_redirect_uri: redirect, notice: "Todoを#{finish ? '完了する' : '未完了に戻す'}処理に成功しました"
  end

  def edit_user_property_schedule
    @item = Gw::Property::TodoSetting.where(uid: Core.user.id).first_or_new
    if @item.todos_display_schedule == '1'
      @item.todos_display_schedule = '0'
      return_str = "off"
    else
      @item.todos_display_schedule = '1'
      return_str = "on"
    end

    if @item.save
      render :text => return_str
    else
      render :text => "NG"
    end
  end
end
