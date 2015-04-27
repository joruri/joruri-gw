class Gw::Admin::ScheduleEventsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  before_action :check_auth, only: [:approval, :approval_cancel, :open, :open_cancel, :select_approval_open]

  def pre_dispatch
    redirect_to "/gw/schedule_events/?p=#{params[:p]}" if params[:reset].present?

    Page.title = "週間・月間行事予定"
    @model = Gw::ScheduleEvent
    @db_name = "gw_schedule_events"
    @sp_mode = :schedule

    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css /_common/themes/gw/css/prop_extra/pm_rentcar.css)

    if params[:p].blank? || params[:p] == "week"
      @pattern = "week"
      @title_piece = "週間"
    elsif params[:p] == "month"
      @pattern = "month"
      @title_piece = "月間"
    end

    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin

    # 権限
    @is_ev_admin = Gw::ScheduleEvent.is_ev_admin?                   # 月間・週刊行事予定の管理者。ロールで設定。
    @is_ev_management_edit_auth = Gw::ScheduleEventMaster.is_ev_management_edit_auth?   # 月間・週刊行事予定の主管課。主管課マスタ（schedule_event_masters）で設定。
    @is_ev_management = Gw::ScheduleEventMaster.is_ev_management?   # 月間・週刊行事予定の主管課。主管課マスタ（schedule_event_masters）で設定。
    @is_ev_operator = Gw::ScheduleEvent.is_ev_operator?             # 管理画面の編集権限。月間・週刊行事予定の管理者と主管課（承認あり）。
    @is_ev_reader  = Gw::ScheduleEvent.is_ev_reader?                # 管理画面の表示権限。月間・週刊行事予定の管理者と主管課。

    params[:p] = params[:p].presence || 'week'
  end

  def url_options
    super.merge(params.slice(:p, :page, :s_approval, :s_open, :s_st_at, :sort_keys, :s_gid).symbolize_keys) 
  end

  def index
    # 主管課用の範囲
    range_gids = Gw::ScheduleEventMaster.range_gids(Core.user.id, {:func_name => 'gw_event'})
    range_parent_gids = Gw::ScheduleEventMaster.range_parent_gids(Core.user.id, {:func_name => 'gw_event'})
    gids = range_gids + range_parent_gids

    if @is_ev_management
      params[:s_approval] = params[:s_approval] || "0"
    elsif !@is_ev_reader
      params[:s_approval] = params[:s_approval] || "1"
    end

    if @is_ev_management
      params[:s_open] = params[:s_open] || "0"
    elsif !@is_ev_reader
      params[:s_open] = params[:s_open] || "1"
    end

    if @is_ev_admin
      @select_gid_list = [['すべて','']] + Gw::ScheduleEvent.select_parent_gid_options(@pattern)
    elsif @is_ev_management
      @select_gid_list = [['すべて','']] + range_gids + range_parent_gids
    else
      @select_gid_list = [['すべて','']]
    end
    @select_gid_list.uniq!

    items = @model.eager_load(:schedule).where("event_#{@pattern}" => 1)
    items = items.where(gid: Core.user_group.id) unless @is_ev_reader

    items = items.where("#{@pattern}_approval" => params[:s_approval]) if params[:s_approval].present?
    items = items.where("#{@pattern}_open" => params[:s_open]) if params[:s_open].present?

    if params[:s_st_at].present? && Gw.is_valid_date_str?(params[:s_st_at])
      st_at = params[:s_st_at].to_date
      ed_at = @pattern == "week" ? st_at + 6 : st_at.end_of_month
      items = items.start_at_between(st_at, ed_at)
    end
 
    if params[:s_gid].present? && (group = System::Group.find_by(id: params[:s_gid]))
      items = items.where(gid: group.self_and_enabled_descendants.map(&:id))
    end

    if @is_ev_management && !@is_ev_admin
      gids = range_gids.map(&:last)
      parent_gids = range_parent_gids.map(&:last)
      if gids.length > 0 && parent_gids.length > 0
        items = items.where([@model.arel_table[:gid].in(gids), @model.arel_table[:parent_gid].in(parent_gids)].reduce(:or))
      elsif gids.length > 0
        items = items.where(gid: gids)
      elsif parent_gids.length > 0
        items = items.where(parent_gid: parent_gids)
      else
        items = items.where(gid: 0, parent_gid: 0)
      end
    end

    if params[:sort_keys].present?
      column, value = params[:sort_keys].split(' ')
      items = items.order(column => value.to_sym) if @model.column_names.include?(column) && value.in?(%w(asc desc))
    end

    @items = items.order(st_at: :desc).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @model.find(params[:id])
  end

  def approval
    item = @model.find(params[:id])

    unless item.event_master_auth?
      return redirect_to url_for(action: :show), notice: "承認権限がありません。承認は主管課のみ可能です。"
    end

    if item.approved?(@pattern)
      return redirect_to url_for(action: :show), notice: "既に承認済のため承認処理はスキップしました。"
    end

    if item.approve!(@pattern)
      flash[:notice] = "行事の承認が完了しました。"
    else
      flash[:notice] = "行事の承認に失敗しました。"
    end

    redirect_to url_for(action: :show)
  end

  def approval_cancel
    item = @model.find(params[:id])

    unless item.event_master_auth?
      return redirect_to url_for(action: :show), notice: "承認権限がありません。承認取消は主管課のみ可能です。"
    end

    unless item.approved?(@pattern)
      return redirect_to url_for(action: :show), notice: "既に未承認状態のため承認取消処理はスキップしました。"
    end

    if item.unapprove!(@pattern)
      flash[:notice] = "行事の承認取消が完了しました。"
    else
      flash[:notice] = "行事の承認取消に失敗しました。"
    end

    redirect_to url_for(action: :show)
  end

  def open
    item = @model.find(params[:id])

    unless @is_ev_admin
      return redirect_to url_for(action: :show), notice: "公開権限がありません。公開は行事予定の管理者のみ可能です。"
    end

    if item.opened?(@pattern)
      return redirect_to url_for(action: :show), notice: "既に公開済のため公開処理はスキップしました。"
    end

    unless item.approved?(@pattern)
      return redirect_to url_for(action: :show), notice: "主管課が未承認です。公開前に主管課の承認が必要です。"
    end

    if item.open!(@pattern)
      flash[:notice] = "行事の公開が完了しました。"
    else
      flash[:notice] = "行事の公開に失敗しました。"
    end

    redirect_to url_for(action: :show)
  end

  def open_cancel
    item = @model.find(params[:id])

    unless @is_ev_admin
      return redirect_to url_for(action: :show), notice: "公開権限がありません。公開取消は行事予定の管理者のみ可能です。"
    end

    unless item.opened?(@pattern)
      return redirect_to url_for(action: :show), notice: "既に未公開のため公開取消処理はスキップしました。"
    end

    unless item.approved?(@pattern)
      return redirect_to url_for(action: :show), notice: "主管課が未承認です。公開前に主管課の承認が必要です。"
    end

    if item.close!(@pattern)
      flash[:notice] = "行事の公開取消が完了しました。"
    else
      flash[:notice] = "行事の公開取消に失敗しました。"
    end

    redirect_to url_for(action: :show)
  end

  def select_approval_open
    if params[:ids].blank?
      return redirect_to url_for(action: :index), notice: "対象が選択されていません。"
    end

    case
    when params[:approval_submit]
      notice = approve_multi
    when params[:approval_cancel_submit]
      notice = unapprove_multi
    when params[:open_submit]
      return error_auth unless @is_ev_admin
      notice = open_multi
    when params[:open_cancel_submit]
      return error_auth unless @is_ev_admin
      notice = close_multi
    end

    redirect_to url_for(action: :index), notice: notice
  end

  private

  def approve_multi
    success = 0
    failure = 0
    already_approved = 0
    no_auth = 0

    @model.where(id: params[:ids]).each do |item|
      if item.approved?(@pattern)
        already_approved += 1
        next
      end

      unless item.event_master_auth?
        no_auth += 1
        next
      end

      if item.approve!(@pattern)
        success += 1
      else
        failure += 1
      end
    end

    notices = []
    if success == 0
      notices << "承認できた行事はありませんでした。"
    else
      notices << "#{success}件の行事を承認しました。"
    end
    notices << "なお、既に承認済の行事が#{already_approved}件ありました。" if already_approved > 0
    notices << "また、主管課の権限が無いため承認できなかった行事が#{no_auth}件ありました。" if no_auth > 0
    notices << "また、#{failure}件の行事の承認に失敗しました。" if failure > 0
    notices.join("<br />")
  end

  def unapprove_multi
    success = 0
    failure = 0
    not_approved = 0
    no_auth = 0
    already_opened = 0

    @model.where(id: params[:ids]).each do |item|
      unless item.approved?(@pattern)
        not_approved += 1
        next
      end

      if item.opened?(@pattern)
        already_opened += 1
        next
      end

      unless item.event_master_auth?
        no_auth += 1
        next
      end

      if item.unapprove!(@pattern)
        success += 1
      else
        failure += 1
      end
    end

    notices = []
    if success == 0
      notices << "承認取消できた行事はありませんでした。"
    else
      notices << "#{success}件の行事の承認を取り消しました。"
    end
    notices << "なお、未承認の行事が#{not_approved}件ありました。" if not_approved > 0
    notices << "また、既に公開済の行事が#{already_opened}件ありました。" if already_opened > 0
    notices << "また、主管課の権限が無いため承認取消できなかった行事が#{no_auth}件ありました。" if no_auth > 0
    notices << "また、#{failure}件の行事の承認取消に失敗しました。" if failure > 0
    notices.join("<br />")
  end

  def open_multi
    success = 0
    failure = 0
    not_approved = 0
    already_opened = 0

    @model.where(id: params[:ids]).each do |item|
      unless item.approved?(@pattern)
        not_approved += 1
        next
      end

      if item.opened?(@pattern)
        already_opened += 1
        next
      end

      if item.open!(@pattern)
        success += 1
      else
        failure += 1
      end
    end

    notices = []
    if success == 0
      notices << "公開できた行事はありませんでした。"
    else
      notices << "#{success}件の行事を公開しました。"
    end
    notices << "なお、既に公開済の行事が#{already_opened}件ありました。" if already_opened > 0
    notices << "また、未承認の行事が#{not_approved}件ありました。" if not_approved > 0
    notices << "また、#{failure}件の行事の公開に失敗しました。" if failure > 0
    notices.join("<br />")
  end

  def close_multi
    success = 0
    failure = 0
    not_opened = 0

    @model.where(id: params[:ids]).each do |item|
      unless item.opened?(@pattern)
        not_opened += 1
        next
      end

      if item.close!(@pattern)
        success += 1
      else
        failure += 1
      end
    end

    notices = []
    if success == 0
      notices << "公開取消できた行事はありませんでした。"
    else
      notices << "#{success}件の行事の公開を取り消しました。"
    end
    notices << "なお、既に未公開の行事が#{not_opened}件ありました。" if not_opened > 0
    notices << "また、#{failure}件の行事の公開取消に失敗しました。" if failure > 0
    notices.join("<br />")
  end

  def check_auth
    return error_auth unless @is_ev_operator
  end
end
