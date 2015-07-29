# encoding: utf-8
class Gw::Admin::MemosController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/memo"

  def memo_path
    gw_memos_path
  end

  def initialize_scaffold
    @css = %w(/_common/themes/gw/css/memo.css)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @s_index_cls = nz(params[:s_index_cls],'1')
    @s_finished = nz(params[:s_finished],'1')

    session[:s_send_cls] = params[:s_send_cls] unless params[:s_send_cls].nil?
    params[:s_send_cls] = session[:s_send_cls]

    chk = request.headers['HTTP_USER_AGENT']
    firefox_chk = chk.index("Firefox")
    ie_chk = chk.index("MSIE")
    ie_chk = chk.index("Trident") if ie_chk.blank?
    chrome_chk = chk.index("Chrome")
    if ie_chk.blank? && !firefox_chk.blank? && chrome_chk.blank?
      @firefox = true
    else
      @firefox = false
    end

    Page.title = "連絡メモ"
    @redirect_uri = gw_memos_path({:s_finished=>@s_finished})
    params[:limit] = 10 if request.mobile?

  end

  def index
    item = Gw::Memo.new
    item.page  params[:page], params[:limit]

    d = Date.today
    uid = Core.user.id
    cond_recv = Gw::Model::Memo.recv_cond(uid)

    cond_send = Gw::Model::Memo.send_cond(uid)
    cond_date = Gw::Model::Memo.date_cond_main(d)
    @s_send_cls = nz(params[:s_send_cls], "1")
    cond = case @s_send_cls
    when "2"
      "#{cond_send}"
    when "3"
      "((#{cond_send}) or (#{cond_recv}))"
    else
      "#{cond_recv}"
    end
    cond += case params[:s_finished]
    when "2"
      ' and coalesce(is_finished, 0) = 1'
    when "3"
      ''
    else
      ' and coalesce(is_finished, 0) != 1'
    end

    @qsa = Gw.params_to_qsa(%w(s_send_cls s_finished s_index_cls), params)
    @qs = Gw.qsa_to_qs(@qsa,{:no_entity=>true})
    @sort_keys = CGI.unescape(nz(params[:sort_keys], ''))
    sk = @sort_keys
    if /^(_.+?) (.+)$/ =~ sk
      sort_ext_flg = 1
      sort_ext_key = $1
      sort_ext_order = $2
      sk = ''
    end
    order = Gw.join([sk, "#{Gw.order_last_null 'gw_memos.created_at', :order=>'desc'}"], ',')

    if @s_send_cls == '2'
      @items = item.find(:all,
        :conditions => cond,
        :select=>'gw_memos.*', :order => order)
    else
      @items = item.find(:all,
        :conditions => cond, :joins=>'left join gw_memo_users on gw_memos.id = gw_memo_users.schedule_id',
        :select=>'gw_memos.*', :order => order)
    end
    @items.sort!{|a,b| sort_ext_order == 'asc' ? (a.send(sort_ext_key) <=> b.send(sort_ext_key)) : (b.send(sort_ext_key) <=> a.send(sort_ext_key))} if sort_ext_flg

  end

  def show
    item = Gw::Memo.new
    @item = item.find(params[:id])
  end

  def new
    @item = Gw::Memo.new({})
    if request.mobile?
      unless flash[:mail_to].blank?
        @users_json = @item.set_participants(flash[:mail_to]).to_json
      end
    end
  end

  def quote
    @item = Gw::Memo.new.find(params[:id])
    if request.mobile?
      unless flash[:mail_to].blank?
        @users_json = @item.set_participants(flash[:mail_to]).to_json
      end
    end
  end

  def edit
    @item = Gw::Memo.new.find(params[:id])
    @users_json = get_user_json(@item.memo_users)
    if request.mobile?
      unless flash[:mail_to].blank?
        @users_json = @item.set_participants(flash[:mail_to]).to_json
      end
    end
  end

  def create
    @item = Gw::Memo.new()
    if request.mobile?
      params[:item] = @item.mobile_params(params[:item])
    end

    if @item.save_with_rels params[:item], :create
      flash_notice '連絡メモの登録', true
      redirect_to gw_memos_path({:s_send_cls=>2})

    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @item = Gw::Memo.find(params[:id])
    if request.mobile?
      params[:item] = @item.mobile_params(params[:item])
    end
    if @item.save_with_rels params[:item], :update
      flash_notice '連絡メモの編集', true
      redirect_to gw_memo_path(@item)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @item = Gw::Memo.find(params[:id])
    _destroy(@item,:success_redirect_uri=>gw_memos_path)
  end

  def finish
    @item = Gw::Memo.find(params[:id])
    item = {}
    act = nz(@item.is_finished, 0) != 1
    item[:is_finished] = act ? 1 : nil
    @item.attributes = item
    _update @item, :success_redirect_uri => '/gw/memos', :notice => "連絡メモを#{act ? '既読にする' : '未読に戻す'}処理に成功しました"
  end

  def setting_ind_memos

  end

  def setting_ind_core(key)
    @item = Gw::Model::Schedule.get_settings key
  end

  def list
    s_send_cls  = nz(params[:s_send_cls], "1")
    s_index_cls = nz(params[:s_index_cls], "1")
    s_finished  = nz(params[:s_finished], "1")
    if !params[:finished_submit].blank?
      finished_cnt = 0
      finished_cnt_no = 0
      if params[:ids] and params[:ids].size > 0
        for id in params[:ids]
          item = Gw::Memo.find(id)
          if s_finished != '2'
            if item.is_finished.blank?
              item.is_finished = 1
              ret_save = item.save
              finished_cnt += 1
            else
              finished_cnt_no += 1
            end
          else
            if item.is_finished==1
              item.is_finished = nil
              ret_save = item.save
              finished_cnt += 1
            else
              finished_cnt_no += 1
            end
          end
        end
        if s_finished != '2'
          if finished_cnt == 0
            notice_str = %Q(チェックされたメモに、未読のデータは存在しませんでした。)
          else
            if finished_cnt_no == 0
              notice_str = "既読にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。"
            else
              notice_str = "既読にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。なお、すでに既読のメモが#{finished_cnt_no}存在しており、それらは変更しておりません。"
            end
          end
        else
          if finished_cnt == 0
            notice_str = %Q(チェックされたメモに、既読のデータは存在しませんでした。)
          else
            if finished_cnt_no == 0
              notice_str = "未読にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。"
            else
              notice_str = "未読にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。なお、すでに未読のメモが#{finished_cnt_no}存在しており、それらは変更しておりません。"
            end
          end
        end
        flash[:notice] = notice_str
      else
        flash[:notice] = "対象が選択されていません"
      end
      redirect_uri = "#{memo_path}?s_send_cls=#{s_send_cls}&s_index_cls=#{s_index_cls}&s_finished=#{s_finished}"
      redirect_to redirect_uri
    end
    if !params[:delete_submit].blank?
      delete_cnt = 0
      delete_cnt_no = 0
      if params[:ids] and params[:ids].size > 0
        for id in params[:ids]
          ret_del1 = Gw::MemoUser.delete_all("schedule_id=#{id}")
          ret_del2 = Gw::Memo.delete(id)
          ret_del = ret_del1 & ret_del2
          if ret_del
            delete_cnt += 1
          else
            delete_cnt_no += 1
          end
        end
        if delete_cnt == 0
          flash[:notice] = "チェックされたメモに、削除対象のデータは存在しませんでした。"
        else
          flash[:notice] = "削除に#{ret_del ? '成功' : '失敗'}しました(成功数=#{delete_cnt})。"
        end
      else
        flash[:notice] = "対象が選択されていません"
      end
      redirect_uri = "#{memo_path}?s_send_cls=#{s_send_cls}&s_index_cls=#{s_index_cls}&s_finished=#{s_finished}"
      redirect_to redirect_uri
    end
    redirect_uri = "#{memo_path}?s_send_cls=#{s_send_cls}&s_index_cls=#{s_index_cls}&s_finished=#{s_finished}"
  end

  def confirm
    item = Gw::Memo.new
    @item = item.find(params[:id])
  end

  def delete
    @item = Gw::Memo.find(params[:id])
    _destroy(@item,:success_redirect_uri=>gw_memos_path)
  end

private
  def get_user_json(memo_users)
    users = []
    memo_users.each do |user|
      mobile_class = 'mobileOff'
      keitai_str = '&nbsp;&nbsp;&nbsp;&nbsp;'
      property = Gw::UserProperty.new.find(:first, :conditions=>["uid = ? and class_id = 1 and name = 'mobile'", user.uid])
      if !property.blank? && property.is_email_mobile?
        mobile_class = 'mobileOn'
        keitai_str = 'M&nbsp;&nbsp;'
      end
      users.push [user.class_id, user.uid, "#{keitai_str if !@firefox}#{Gw.trim(user.user.display_name)}", mobile_class]
    end
    users.to_json
  end
end
