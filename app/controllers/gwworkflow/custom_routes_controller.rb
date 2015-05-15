class Gwworkflow::CustomRoutesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find(params[:title_id])

    Page.title = "ワークフロー カスタムルート設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def index
    @items = load_items
    _index @items
  end

  def new
    @item = Gwworkflow::CustomRoute.new(
      state: 'enabled',
      sort_no: '10',
      owner_uid: Core.user.id
    )
  end

  def create
    @item = Gwworkflow::CustomRoute.new
    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]
    @item.owner_uid = Core.user.id

    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }

    _create @item
  end

  def edit
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
  end

  def update
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id

    @item.state = params[:item][:state]
    @item.sort_no = params[:item][:sort_no]
    @item.name = params[:item][:name]

    @item.steps.each{|s|s.destroy}
    (params[:committees]||[]).map{|s| s.to_i }.map{|id|
      user = System::User.find(id); [ id, user.name, user.group_name ]
    }.each.with_index{|(id,name,gname),idx|
      step = @item.steps.build :number => idx
      step.committees.build :user_id => id, :user_name => name, :user_gname => gname
    }

    _update @item
  end

  def destroy
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
    _destroy @item
  end

  def sort_update
    @items = load_items
    @items.each {|item| item.attributes = params[:items][item.id.to_s] if params[:items][item.id.to_s] }
    _index_update @items
  end

private

  def load_items
    Gwworkflow::CustomRoute.where(owner_uid: Core.user.id)
      .order(sort_no: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
