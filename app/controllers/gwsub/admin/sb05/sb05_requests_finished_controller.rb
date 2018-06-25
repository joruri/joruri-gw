class Gwsub::Admin::Sb05::Sb05RequestsFinishedController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
#    pp ['initialize',params]
    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

  def index
    init_params
    item = Gwsub::Sb05Request.new
    item.search params
    item.and 'sql'," start_at is not null"
    item.and 'sql'," base_at = '#{Gw.date_str(@base_at)} 00:00:00'" unless @base_at.to_s=='0'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @requests = item.find(:all)
    _index @requests
  end

  def show
    init_params
    @req1 = Gwsub::Sb05Request.find(params[:id])
    user_id = nz(params[:sb05_users_id],@req1.sb05_users_id)
    @user = Gwsub::Sb05User.find(user_id)
    if @user.blank?
      # TODO:連絡先情報がなければ、ログインユーザー（これは連絡先と依頼が不整合の時のみ発生：エラーでいいかもしれない）
      user = Gwsub::Sb05User.new
      user.users_id = Core.user.id
      user.org_code = Core.user_group.code
      user.org_name = Core.user_group.name
      user.order "created_at DESC"
      @user = Gwsub::Sb05User.first
      if @user.blank?
        flash[:notice] = '連絡先情報が見つかりません。'
        return
      end
    end
    req = Gwsub::Sb05Request.new
    req.sb05_users_id = @user.id
    req.org_code = @user.org_code
    req.org_name = @user.org_name
    if params[:r_state]
      req.r_state = params[:r_state]
    end
    @is_get_files   = get_files   #イベント情報/画像ファイルがあったらidを返す。無かったらfalseを返す。
    @is_check_media = check_media #メルマガ/イベント情報のmedia_code,categories_codeを判別し、true,false。
  end

  def list
#pp ['sb05_requests/list' , params]
    # 絞込み・検索条件の引継ぎ
    params1 = make_params
    # 選択一括処理のあとの戻り先一覧
    # redirect uri
    redirect_uri = "/gwsub/sb05/sb05_requests_finished#{params1}"
    # 処理済にする
    if !params[:finished_submit].blank?
      finished_cnt = 0
      finished_cnt_no = 0
      if params[:ids] and params[:ids].size > 0
        for id in params[:ids]
          item = Gwsub::Sb05Request.find(id.to_i)
          if item.blank?
              finished_cnt_no += 1
          else
            if item.r_state != '5'
              item.r_state = '5'
              ret_save = item.save(:validate => false)
              finished_cnt += 1
            else
              finished_cnt_no += 1
            end
          end
        end
        # 処理済にする
        if finished_cnt == 0
          notice_str = %Q(チェックされたデータに、未処理のデータは存在しませんでした。)
        else
          if finished_cnt_no == 0
            notice_str = "処理済にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。"
          else
            notice_str = "処理済にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。なお、すでに処理済が#{finished_cnt_no}存在しており、それらは変更しておりません。"
          end
        end
        flash[:notice] = notice_str
      else
        flash[:notice] = "対象が選択されていません"
      end
    end
    redirect_to redirect_uri
  end

  def finished
    init_params
    req1 = Gwsub::Sb05Request.find(params[:id])
    return http_error(404) if req1.blank?
    req1.r_state='5'
    req1.save(:validate => false)
    show_url = gwsub_sb05_requests_finished_path(req, sb05_users_id: req1.sb05_users_id)
    flash[:notice] = flash[:notice] || "処理済にしました。"

    redirect_to show_url
    return
  end
  def finished_off
    init_params
    req1 = Gwsub::Sb05Request.find(params[:id])
    return http_error(404) if req1.blank?
    req1.r_state='4'
    req1.save(:validate => false)
    show_url = gwsub_sb05_requests_finished_path(req, sb05_users_id: req1.sb05_users_id)
    flash[:notice] = flash[:notice] || "未処理に戻しました。"
    redirect_to show_url
    return
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    # 表示条件設定
    # 絞り込み媒体
    @media_code   = nz(params[:media_code],0)
    # 基準日
    @base_at      = nz(params[:b_at],'0')
    # 確認済
    @m_status     = nz(params[:m_status],2)
    # 未処理
    @r_status     = nz(params[:r_status],4)
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='03'
    @l2_current='02'
    return
  end
  def search_condition
    params[:b_at]       = nz(params[:b_at],@base_at)
    params[:media_code] = nz(params[:media_code],@media_code)
    params[:m_status]   = nz(params[:m_status],@m_status)
    params[:r_status]   = nz(params[:r_status],@r_status)
    qsa = ['limit', 's_keyword' ,'media_code' , 'b_at' , 'm_state' , 'r_status' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'media_code ASC , base_at ASC , start_at ASC , created_at ASC')
  end

  # メルマガ　添付画像
  def get_files
    item = Gwsub::Sb05File.new
    item.and :parent_id, @req1.id
    @items = item.find(:all)
    unless @items.length == 0
      return false
    else
      return @items
    end
  end

  def check_media
    return true if params[:media_code].to_i == 4 && params[:cat_code].to_i == 2
  end

  def make_params
    @media_code = params[:media_code]
    @base_at    = params[:b_at]
    @r_status   = params[:r_status]
    @m_status   = params[:m_status]
    @limit      = params[:limit]
    params1 = "?media_code=#{@media_code}"
    params1 += "&b_at=#{@base_at}"
    params1 += "&r_status=#{@r_status}"
    params1 += "&m_status=#{@m_status}"
    params1 += "&limit=#{@limit}"
    return params1
  end

end
