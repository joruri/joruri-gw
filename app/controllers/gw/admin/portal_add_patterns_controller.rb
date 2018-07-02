class Gw::Admin::PortalAddPatternsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @u_role = Gw::PortalAdd.is_admin?
    return error_auth unless @u_role

    Page.title = "広告アイコン管理"
  end

  def index
    @items = Gw::PortalAddPattern.group(:group_id).order(group_id: :asc, sort_no: :asc)
    _index @items
  end

  def show
    @item = Gw::PortalAddPattern.find(params[:id])
  end

  def new
    @item = Gw::PortalAddPattern.new(
      state: 'enabled',
      group_id: Gw::PortalAddPattern.maximum(:group_id).to_i + 10
    )
    @adds = Gw::PortalAdd.order(:sort_no)
  end

  def create
    @item = Gw::PortalAddPattern.new(params[:item])
    @adds = Gw::PortalAdd.order(:sort_no)

    @item.sort_no = 0
    @item.group_patterns.each do |pattern|
      pattern.attributes = {
        state: @item.state, title: @item.title, group_id: @item.group_id,
        pattern: @item.pattern, place: @item.place, skip_validate_size: true
      }
    end

    if @item.valid?
      @item.group_patterns.reject(&:marked_for_destruction?).each(&:save)
      redirect_to url_for(action: :index)
    else
      render action: :new
    end
  end

  def edit
    @item = Gw::PortalAddPattern.find(params[:id])
    @adds = Gw::PortalAdd.order(:sort_no)
  end

  def update
    @item = Gw::PortalAddPattern.find(params[:id])
    @adds = Gw::PortalAdd.order(:sort_no)

    @item.attributes = params[:item]
    @item.group_patterns.each do |pattern|
      pattern.attributes = {
        state: @item.state, title: @item.title, group_id: @item.group_id,
        pattern: @item.pattern, place: @item.place, skip_validate_size: true
      }
    end

    _update @item
  end

  def destroy
    @item = Gw::PortalAddPattern.find(params[:id])
    @item.group_patterns.destroy_all

    redirect_to url_for(action: :index), notice: "グループ設定を一件削除しました。"
  end

  def sort_update
    @item = Gw::PortalAddPattern.find(params[:id])
    @items = Gw::PortalAddPattern.where(group_id: @item.group_id)

    @items.each {|item| item.sort_no = params[:item][item.id.to_s] }

    if @items.all?(&:valid?) && @items.all?(&:save)
      flash_notice '並び順更新', true
      redirect_to url_for(action: :show)
    else
      flash_notice '並び順更新', false
      render :show
    end
  end

  def g_updown
    item = Gw::PortalAddPattern.find(params[:id])
    items = Gw::PortalAddPattern.where(group_id: item.group_id)

    item_rep, items_rep = nil
    case params[:order]
    when 'up'
      item_rep = Gw::PortalAddPattern.where(Gw::PortalAddPattern.arel_table[:group_id].lt(item.group_id)).order(group_id: :desc).group(:group_id).first!
      items_rep = Gw::PortalAddPattern.where(group_id: item_rep.group_id).order(group_id: :desc)
    else
      item_rep = Gw::PortalAddPattern.where(Gw::PortalAddPattern.arel_table[:group_id].gt(item.group_id)).order(group_id: :asc).group(:group_id).first!
      items_rep = Gw::PortalAddPattern.where(group_id: item_rep.group_id).order(group_id: :asc)
    end

    items.each {|i| i.group_id = item_rep.group_id; }
    items_rep.each {|i| i.group_id = item.group_id; }
    items.each {|i| i.save(validate: false) }
    items_rep.each {|i| i.save(validate: false) }

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end
end
