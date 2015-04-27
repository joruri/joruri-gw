class Gw::Admin::PrefAssemblyMemberAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def pre_dispatch
    @role_developer = Gw::PrefAssemblyMember.is_dev?
    @role_admin     = Gw::PrefAssemblyMember.is_admin?
    @u_role = @role_developer || @role_admin
    return error_auth unless @u_role
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    Page.title = "議員在庁表示管理"
    @css = %w(/_common/themes/gw/css/admin.css)
  end

  def url_options
    super.merge(params.slice(:g_cat).symbolize_keys) 
  end

  def index
    @items = 
      if params[:g_cat].present?
        Gw::PrefAssemblyMember.where(g_order: params[:g_cat].to_i)
      else
        Gw::PrefAssemblyMember.group(:g_order)
      end
    @items = @items.order(g_order: :asc, u_order: :asc).paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::PrefAssemblyMember.find(params[:id])
  end

  def new
    @item = Gw::PrefAssemblyMember.new(state: 'off')
    if params[:g_cat].present?
      @item.g_order = params[:g_cat].to_i
      @item.g_name = Gw::PrefAssemblyMember.where(g_order: params[:g_cat].to_i).first.try(:g_name)
    end
  end

  def create
    @item = Gw::PrefAssemblyMember.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::PrefAssemblyMember.find(params[:id])
  end

  def update
    @item = Gw::PrefAssemblyMember.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::PrefAssemblyMember.find(params[:id])
    @item.state = 'disabled'
    @item.deleted_at = Time.now
    @item.deleted_user = Core.user.name
    @item.deleted_group = Core.user_group.name

    _update @item
  end

  def csvput
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gw::PrefAssemblyMember.order(:g_order, :u_order).to_csv(headers: ['会派表示順','会派','議員表示順','姓','名','在席情報']) do |item|
      data = [item.g_order, item.g_name, item.u_order, item.u_lname, item.u_name]
      data << (item.state == "on" ? "在席" : "不在")
      data
    end
    send_data @item.encode(csv), type: 'text/csv', filename: "giin_zaicho_#{@item.encoding}.csv"
  end

  def csvup
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gw::PrefAssemblyMember.transaction do
      Gw::PrefAssemblyMember.truncate_table
      items = Gw::PrefAssemblyMember.from_csv(@item.file_data) do |row|
        Gw::PrefAssemblyMember.new(
          g_order: row['会派表示順'],
          g_name: row['会派'],
          u_order: row['議員表示順'],
          u_lname: row['姓'],
          u_name: row['名'],
          state: row['在席情報'] == '在席' ? 'on' : 'off'
        )
      end
      items.each(&:save)
    end

    redirect_to url_for(action: :index), notice: "CSVファイルの読み込みが完了しました。"
  end

  def updown
    item = Gw::PrefAssemblyMember.find(params[:id])

    item_rep = 
      case params[:order]
      when 'up'
        Gw::PrefAssemblyMember.where(g_order: item.g_order).where("u_order < #{item.u_order}").order(u_order: :desc).first!
      when 'down'
        Gw::PrefAssemblyMember.where(g_order: item.g_order).where("u_order > #{item.u_order}").order(u_order: :asc).first!
      end

    item.u_order, item_rep.u_order = item_rep.u_order, item.u_order
    item.save(validate: false)
    item_rep.save(validate: false)

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end

  def g_updown
    item = Gw::PrefAssemblyMember.find(params[:id])

    item_rep = 
      case params[:order]
      when 'up'
        Gw::PrefAssemblyMember.where("g_order < #{item.g_order}").order(g_order: :desc).group(:g_order).first!
      else
        Gw::PrefAssemblyMember.where("g_order > #{item.g_order}").order(g_order: :asc).group(:g_order).first!
      end

    item.group_members.each {|m| m.g_order = item_rep.g_order }
    item_rep.group_members.each {|m| m.g_order = item.g_order }
    item.group_members.each {|m| m.save(validate: false) }
    item_rep.group_members.each {|m| m.save(validate: false) }

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end
end
