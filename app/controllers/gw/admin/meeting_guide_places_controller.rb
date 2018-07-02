class Gw::Admin::MeetingGuidePlacesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "会議室案内表示　会議場所管理"

    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @meetings_guide_admin = @is_gw_admin ? true : Gw::Model::Schedule.meetings_guide_admin? # 会議開催案内 管理者
    @u_role = @is_gw_admin || @meetings_guide_admin
    return error_auth unless @u_role

    @model = Gw::MeetingGuidePlace
  end

  def index
    @items = @model.order(sort_no: :asc).paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @model.find(params[:id])
  end

  def new
    @item = @model.new(
      state: 'enabled',
      place_master: nil,
      place_type: 1,
      prop_id: nil,
      sort_no: Gw::MeetingGuidePlace.maximum(:sort_no).to_i + 10
    )
  end

  def create
    @item = @model.new(params[:item])
    _create @item, notice: '場所の登録に成功しました。'
  end

  def edit
    @item = @model.find(params[:id])
  end

  def update
    @item = @model.find(params[:id])
    @item.attributes = params[:item]
    _update @item, notice: '場所の更新に成功しました。'
  end

  def destroy
    @item = @model.find(params[:id])
    @item.state       = 'deleted'
    @item.sort_no     = nil
    @item.deleted_at  = Time.now
    @item.deleted_uid = Core.user.id
    @item.deleted_gid = Core.user_group.id
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "場所を削除しました。"
  end


  def sort_update
    @items = @model.order(sort_no: :asc)
    params[:items].each do |id, param|
      item = @items.detect{|i| i.id == id.to_i}
      item.attributes = param if item
    end

    if @items.map(&:valid?).all?
      @items.each(&:save)
      redirect_to url_for(action: :index), notice: '並び順を更新しました。'
    else
      flash.now[:notice] = '並び順の更新に失敗しました。'
      render :index
    end
  end

  def updown
    item = @model.find(params[:id])

    item_rep =
      case params[:order]
      when 'up'
        @model.where(@model.arel_table[:sort_no].lt(item.sort_no)).order(sort_no: :desc).first!
      when 'down'
        @model.where(@model.arel_table[:sort_no].gt(item.sort_no)).order(sort_no: :asc).first!
      end

    item.sort_no, item_rep.sort_no = item_rep.sort_no, item.sort_no
    item.save(validate: false)
    item_rep.save(validate: false)

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end

  def prop_sync
    @model.where(place_type: 2).update_all(place_type: -1)

    Gw::PropMeetingroom.order(:sort_no).each do |meeting|
      item = @model.where(prop_id: meeting.id).first || @model.new

      if meeting.delete_state == 1
        item.state         = 'deleted'
        item.deleted_at    = Time.now
        item.deleted_uid   = Core.user.id
        item.deleted_gid   = Core.user_group.id
        item.sort_no       = nil
      else
        item.state         = meeting.reserved_state == 0 ? 'disabled' : 'enabled'
        item.deleted_at    = nil
        item.deleted_uid   = nil
        item.deleted_gid   = nil
        item.sort_no     ||= Gw::MeetingGuidePlace.maximum(:sort_no).to_i + 10
      end

      item.place         ||= "#{meeting.name} （#{meeting.position}）"[0..19]
      item.place_master    = meeting.name
      item.place_type      = 2
      item.prop_id         = meeting.id
      item.save
    end

    @model.where(place_type: -1).update_all(
      place_type: 2,
      state: 'deleted',
      deleted_at: Time.now,
      deleted_uid: Core.user.id,
      deleted_gid: Core.user_group.id
    )

    redirect_to url_for(action: :index), notice: "会議室との同期に成功しました。"
  end
end
