class Gwmonitor::Admin::Menus::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find(params[:title_id])
    page_limit_default_setting
  end

  def index
    redirect_to '/gwmonitor'
  end

  def show
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned?
    return if @title.spec_config < 3

    @items = @title.docs.without_preparation.without_target_user(Core.user)
      .order(state: :asc, section_sort: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def new
    redirect_to '/gwmonitor'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned? unless @title.spec_config == 5
  end

  def update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned?

    @item.attributes = doc_params
    @item.latest_updated_at = Time.now
    @item.set_creater_editor

    unless params[:answer_body].blank?
      body_param = params[:answer_body]
      body_str = ""
      answer_str = "["
      remark_str = "["
      unless body_param[:answer].blank?
        body_param[:answer].each_with_index{|ans, idx|
          answer_str += %Q("#{ans}")
          answer_str += "," if idx != 9
        }
        answer_str += "]"
      end

      unless body_param[:remark].blank?
        body_param[:remark].each_with_index{|rem, idx|
          remark_str += %Q("#{rem}")
          remark_str += "," if idx != 9
        }
        remark_str += "]"
      end
      body_str = %Q([#{answer_str},#{remark_str}])
      @item.body = body_str
    end if @title.form_id == 2

    _update @item, success_redirect_uri: @item.show_path
  end

  def editing_state_setting
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned?

    @item.state = 'editing'
    @item.latest_updated_at = Time.now
    @item.set_creater_editor

    _update @item, success_redirect_uri: @item.show_path
  end

  def draft_state_setting
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned?

    @item.state = 'draft'
    @item.latest_updated_at = Time.now
    @item.set_creater_editor

    _update @item, success_redirect_uri: @item.show_path
  end

  def clone
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_commissioned?

    if @new_title = @title.duplicate
      redirect_to @new_title.edit_path
    else
      flash[:notice] = '複製に失敗しました'
      redirect_to @item.show_path
    end
  end

private

  def doc_params
    params.require(:item).permit(:title, :body, :state, :answer=>[], :remark=>[])
  end

end
