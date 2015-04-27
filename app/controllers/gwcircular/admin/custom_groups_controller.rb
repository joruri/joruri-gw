class Gwcircular::Admin::CustomGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gwcircular"

  def pre_dispatch
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])
    return error_auth unless @title.is_readable?

    @css = ["/_common/themes/gw/css/circular.css"]
    params[:limit] = 200
    Page.title = "配信先個人設定"
  end

  def index
    item = Gwcircular::CustomGroup.new
    item.and :owner_uid , Core.user.id
    item.order 'sort_no, id'
    item.page params[:page], params[:limit]
    @items = item.find(:all)
  end

  def show

  end

  def new
    @item = Gwcircular::CustomGroup.new({
      :state => 'enabled',
      :sort_no => 10
    })
  end

  def create
    @item = Gwcircular::CustomGroup.new(params[:item])
    @item.owner_uid = Core.user.id
    _create @item
  end

  def edit
    @item = Gwcircular::CustomGroup.find(params[:id])
    return error_auth  unless @item.owner_uid == Core.user.id
  end

  def update
    @item = Gwcircular::CustomGroup.find(params[:id])
    return http_error(404) unless @item
    return error_auth  unless @item.owner_uid == Core.user.id

    @item.attributes = params[:item]
    @item.owner_uid = Core.user.id
    _update(@item)
  end

  def destroy
    @item = Gwcircular::CustomGroup.find(params[:id])
    return error_auth  unless @item.owner_uid == Core.user.id
    _destroy @item
  end

  def sort_update
    item = Gwcircular::CustomGroup.new
    item.and :owner_uid , Core.user.id
    item.order 'sort_no, id'
    item.page params[:page], params[:limit]
    @items = item.find(:all)

    @item = Gwcircular::CustomGroup.new
    unless params[:item].blank?
      params[:item].each do |key,value|
        cgid = key.gsub(/sort_no_/, '').to_i
        if item = @items.find{|x| x.id == cgid}
          item.sort_no = value
          unless item.valid?
            item.errors.to_a.each{|msg| @item.errors.add(:base, msg)}
            break
          end
        end
      end
    end

    if @item.errors.size == 0
      @items.each{|item| item.save}
      flash_notice 'カスタムグループの並び順更新', true
      redirect_to '/gwcircular/custom_groups'
    else
      respond_to do |format|
        format.html { render :action => "index" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
