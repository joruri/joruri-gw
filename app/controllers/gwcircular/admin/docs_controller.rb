class Gwcircular::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwcircular"

  before_action :check_title_readable

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find(params[:title_id])

    Page.title = "回覧板"
    @css = ["/_common/themes/gw/css/circular.css"]

    s_state = ''
    s_state = "?state=#{params[:state]}" unless params[:state].blank?
    return redirect_to("#{Site.current_node.public_uri}#{s_state}") if params[:reset]

    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank?
      item = Gwcircular::Doc.find(params[:id])
      unless item.blank?
        if item.doc_type == 0
          params[:cond] = 'owner'
        end
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end
      end
    end
  end

  def index
    redirect_to "#{@title.item_home_path}"
  end

  def show
    @item = @title.docs.find(params[:id])
    return http_error(404) if @item.state == 'preparation'
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    if (@item.state == 'unread' || @item.state == 'mobile') && @item.confirmation != 1
      if request.mobile?
        @item.state = 'mobile'
      else
        @item.state = 'already'
      end
      @item.published_at = Time.now
      @item.latest_updated_at = Time.now
      @item.set_creater_editor
      @item.save
      params[:cond] = 'already'
    end

    @parent = @title.docs.find(@item.parent_id)

    @commissions = @parent.children.without_preparation
      .where.not(target_user_code: Core.user.code)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    @parent = @title.docs.find(@item.parent_id)
  end

  def update
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    @parent = @title.docs.find(@item.parent_id)

    @item.attributes = params[:item]

    @item.published_at ||= Time.now if @item.state_was == 'unread'
    @item.latest_updated_at = Time.now
    @item.set_creater_editor

    _update @item, :success_redirect_uri => "#{@item.show_path}?cond=#{params[:cond]}"
  end

  def unread_update
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    @item.state = 'unread'
    @item.published_at = nil
    @item.save

    Gw::Circular.where(gid: @item.id).update_all(state: 1)

    flash[:notice] = "回覧状態を「未読」に変更しました。"
    if @item.confirmation == 1
      redirect_to "#{@item.show_path}?cond=unread"
    else
      redirect_to @item.item_home_path
    end
  end

  def already_update
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    if request.mobile?
      @item.state = 'mobile'
    else
      @item.state = 'already'
    end
    @item.latest_updated_at = Time.now
    @item.published_at = Time.now
    @item.set_creater_editor
    @item.save

    redirect_to "#{@item.show_path}?cond=already"
  end

  private

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end
end
