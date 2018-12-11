class System::Admin::GroupChangesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "組織変更"
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor
    return error_auth unless @u_role

    @limit = nz(params[:limit],30)
    @css = %w(/layout/admin/style.css)
    @start_at = get_start_at
  end

  def get_start_at
    fyears = System::GroupChangeDate.order(start_at: :desc).first
    if fyears.blank?
      return nil
    end
    if fyears.start_at.blank?
      return nil
    end

    start_at_str = fyears.start_at.strftime("%Y-%m-%d 00:00:00")
    return start_at_str
  end

  def index

    item = Gwboard::RenewalGroup
    show_start_at = @start_at
    if !show_start_at.blank?
      item = item.where(start_date: show_start_at)
    end
    @items = item.order(:incoming_group_code)
  end

  def show
    @item = Gwboard::RenewalGroup.where(:id => params[:id]).first
  end

  def new
    @item = Gwboard::RenewalGroup.new(
      :start_date => @start_at
    )
  end

  def create
    @item = Gwboard::RenewalGroup.new(group_change_params)
    @item.start_date = @start_at if @item.start_date.blank?
    _create @item
  end

  def edit
    @item = Gwboard::RenewalGroup.where(:id => params[:id]).first
  end

  def update
    @item = Gwboard::RenewalGroup.where(:id => params[:id]).first
    @item.attributes = group_change_params
    if @item.save
      flash[:notice]="組織変更データを編集しました"
    else
      flash[:notice]="組織変更データの編集に失敗しました"
    end
    _update @item
  end


  def destroy
    @item = Gwboard::RenewalGroup.where(:id => params[:id]).first
    _destroy @item
  end


  def csvup
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if request.get?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    items = Gwboard::RenewalGroup.from_csv(@item.file_data)
    items.each do |item|
      item.start_date = @start_at
      if g = System::Group.where(state: 'enabled', code: item.present_group_code).first
        item.present_group_id = g.id
      end
    end

    ret = {:result => true, :count => 0, :error => 0}
    items.each do |item|
      if item.save
        ret[:count] += 1
      else
        ret[:error] += 1
      end
    end

    redirect_to url_for(action: :index), notice: "#{ret[:count]}件のデータを登録しました。"
  end

  def do_annual_change(start_at)
    item = Gwboard::RenewalGroup.new
    item.and :start_date, start_at
    items = item.find(:all)
    return false if items.blank?
    items.each do |p_item|
      next unless p_item.incoming_group_id.blank?
      incoming_group = System::Group.new
      incoming_group.and "sql", "end_at IS NULL"
      incoming_group.and :state , "enabled"
      incoming_group.and :code, p_item.incoming_group_code
      i_group = incoming_group.find(:first)
      if i_group.blank?
        return false
      else
        p_item.incoming_group_id = i_group.id
        p_item.save(:validate => false)
      end
    end

    Gwbbs::Script::Annual.renew(start_at)
    Gwqa::Script::Annual.renew(start_at)
    Gwfaq::Script::Annual.renew(start_at)
    Doclibrary::Script::Annual.renew(start_at)
    Digitallibrary::Script::Annual.renew(start_at)
    Gwmonitor::Script::Annual.renew(start_at)
    System::Script::Annual.system_roles_renew(start_at)
    Gw::Script::Annual.renew(start_at)
    Questionnaire::Script::Annual.renew(start_at)

  end

  def reflect
    msg = ""
    if do_annual_change(@start_at)
      msg = "作業を終了しました。"
    else
      msg = "組織変更情報が存在しないか、新所属の設定に誤りがあります。"
    end
    flash[:notice]=msg
    return redirect_to url_for({:action=>:index})
  end

private

  def group_change_params
    params.require(:item).permit(:start_date, :incoming_group_code, :incoming_group_name, :present_group_id)
  end

end
