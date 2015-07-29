# encoding: utf-8
class System::Admin::GroupChangeDatesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    Page.title = "開始日設定"
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor

    @limit = nz(params[:limit],30)
    @css = %w(/layout/admin/style.css)
    return redirect_to "/_admin" unless @u_role
  end

  def index
      item = System::GroupChangeDate.new#.readable
      item.page  params[:page], params[:limit]
      item.order params[:sort], "start_at desc"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = System::GroupChangeDate.new.find(params[:id])
      return authentication_error(404) unless @item.readable?

      _show @item
  end


  def new
      @item = System::GroupChangeDate.new
  end

  def edit
    @item = System::GroupChangeDate.where(:id => params[:id]).first
    return authentication_error(404) unless @item.readable?
  end

  def create
    @item = System::GroupChangeDate.new(params[:item])
    _create @item
  end

  def update
    @item = System::GroupChangeDate.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::GroupChangeDate.where(:id => params[:id]).first
    _destroy @item
  end


end
