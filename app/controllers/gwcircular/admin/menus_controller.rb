class Gwcircular::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwcircular"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]

  def pre_dispatch
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])

    Page.title = "回覧板"
    s_state = ''
    s_state = "?state=#{params[:state]}" unless params[:state].blank?
    return redirect_to("#{gwcircular_menu_path}#{s_state}") if params[:reset]
    @css = ["/_common/themes/gw/css/circular.css"]

    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank?

      item = Gwcircular::Doc.where(:id => params[:id]).first
      unless item.blank?

        if item.doc_type == 0
          params[:cond] = 'owner'
        end unless params[:cond] == 'void'
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end unless params[:cond] == 'void'
      end
    end unless params[:cond] == 'void' unless params[:cond] == 'admin'
    params[:cond] = 'unread' if params[:cond].blank?
  end

  def index
    return error_auth if params[:cond] == 'admin' && !@title.is_admin?

    @items = @title.docs.index_docs_with_params_and_request(params, request)
      .index_order_with_params(params)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    @commissions = @item.children.abled_docs.without_preparation
      .order(state: :desc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def new
    @item = @title.docs.create(
      :state => 'preparation',
      :latest_updated_at => Time.now,
      :doc_type => 0,
      :title => '',
      :body => '',
      :section_code => Core.user_group.code,
      :target_user_id => Core.user.id,
      :target_user_code => Core.user.code,
      :target_user_name => Core.user.name,
      :confirmation => 0,
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => (@title.default_published || 14).days.since.strftime("%Y-%m-%d %H:00"),
      :wiki => 0
    )

    @item.state = 'draft'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?
  end

  def update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.attributes = circular_params
    @item.latest_updated_at = Time.now
    @item.set_creater_editor

    if @title.is_admin?
      @item.target_user_code = Core.user.code if @item.target_user_code.blank?
      @item.target_user_name = Core.user.name if @item.target_user_name.blank?
    else
      @item.target_user_code = Core.user.code
      @item.target_user_name = Core.user.name
    end

    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    _update @item, :success_redirect_uri => "#{gwcircular_menus_path}#{s_cond}"
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    _destroy @item, success_redirect_uri: "#{@title.menus_path}#{s_cond}"
  end

  def clone
    @item = @title.docs.find(params[:id])

    if @new_item = @item.duplicate
      redirect_to @new_item.edit_path
    else
      flash[:notice] = '複製に失敗しました'
      redirect_to @item.show_path
    end
  end

  def circular_publish
    item = @title.docs.find(params[:id])
    item.state = 'public'
    item.save

    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    redirect_to "#{@title.menus_path}#{s_cond}"
  end

  private

  def circular_params
    params.require(:item).permit(:title, :wiki, :body, :wiki_body, :state,
      :expiry_date, :confirmation, :reader_groups_json, :readers_json,
      :reader_groups => [:gid, :uid => []],
      :readers => [:gid, :uid => []])
  end

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end
end
