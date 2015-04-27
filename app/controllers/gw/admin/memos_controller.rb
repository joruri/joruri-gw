class Gw::Admin::MemosController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include DownloadHelper
  layout "admin/template/memo"

  before_action :adjust_params_for_mobile, only: [:create, :update], if: -> { request.mobile? }

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    firefox = firefox_browser(request.headers['HTTP_USER_AGENT'])
    ie = file_name_encode?(request.headers['HTTP_USER_AGENT'])
    chrome = chrome_browser(request.headers['HTTP_USER_AGENT'])
    @mobile_image = !ie && (firefox || chrome)

    Page.title = "連絡メモ"
    @css = %w(/_common/themes/gw/css/memo.css)
    params[:limit] = 10 if request.mobile?
    params[:s_send_cls] ||= '1'
    params[:s_finished] ||= '1'
  end

  def url_options
    super.merge(params.slice(:s_send_cls, :s_index_cls, :s_finished, :sort_keys).symbolize_keys) 
  end

  def index
    @items = Gw::Memo.search_with_params(params).index_order_with_params(params)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:memo_users => :user_property)
  end

  def show
    @item = Gw::Memo.find(params[:id])
  end

  def new
    @item = Gw::Memo.new
    if request.mobile? && flash[:mail_to].present?
      @item.selected_receiver_uids = flash[:mail_to].split(',')
    end
  end

  def quote
    @item = Gw::Memo.find(params[:id])
    if request.mobile? && flash[:mail_to].present?
      @item.selected_receiver_uids = flash[:mail_to].split(',')
    end
  end

  def create
    @item = Gw::Memo.new(params[:item])
    @item.uid = Core.user.id
    _create @item, success_redirect_uri: {action: :index, s_send_cls: 2}, notice: '連絡メモの登録処理が完了しました。' do
      @item.send_mail_after_addition(@item.memo_users.map(&:uid))
    end
  end

  def edit
    @item = Gw::Memo.find(params[:id])
    if request.mobile? && flash[:mail_to].present?
      @item.selected_receiver_uids = flash[:mail_to].split(',')
    end
  end

  def update
    @item = Gw::Memo.find(params[:id])
    @item.attributes = params[:item]
    _update @item, notice: '連絡メモの編集処理が完了しました。' do
      @item.send_mail_after_addition(@item.memo_users.map(&:uid))
    end
  end

  def destroy
    @item = Gw::Memo.find(params[:id])
    _destroy @item
  end

  def finish
    @item = Gw::Memo.find(params[:id])
    @item.is_finished = @item.is_finished? ? 0 : 1

    _update @item, notice: "連絡メモを#{@item.is_finished? ? '既読にする' : '未読に戻す'}処理が完了しました。"
  end

  def list
    case
    when params[:finished_submit]
      to_val, to_str = params[:s_finished] == '2' ? [0, '未読'] : [1, '既読']
      num = Gw::Memo.where(id: params[:ids]).update_all(is_finished: to_val)
      flash[:notice] = "#{num}件のメモを#{to_str}にしました。"
    when params[:delete_submit]
      num = Gw::Memo.where(id: params[:ids]).destroy_all.size
      flash[:notice] = "#{num}件のメモを削除しました。"
    end
    redirect_to url_for(action: :index)
  end

  def confirm
    @item = Gw::Memo.find(params[:id])
  end

  def delete
    @item = Gw::Memo.find(params[:id])
    _destroy @item
  end

  def getajax
    group = System::Group.find(params[:group_id])
    options = Gw::Memo.receiver_options(group.users.pluck(:id), with_image_class: @mobile_image)
    render text: view_context.options_for_select(options)
  end

private

  def adjust_params_for_mobile
    item = params[:item]
    return unless item

    item[:ed_at] = %(#{item['ed_at(1i)']}-#{item['ed_at(2i)']}-#{item['ed_at(3i)']} #{item['ed_at(4i)']}:#{item['ed_at(5i)']})
    item.delete "ed_at(1i)"
    item.delete "ed_at(2i)"
    item.delete "ed_at(3i)"
    item.delete "ed_at(4i)"
    item.delete "ed_at(5i)"
  end
end
