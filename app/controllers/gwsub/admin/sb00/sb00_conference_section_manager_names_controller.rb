class Gwsub::Admin::Sb00::Sb00ConferenceSectionManagerNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch

    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "所属名長管理"
    return redirect_to @index_uri if params[:reset]
  end

  def index
    init_params
    return error_auth unless @u_role==true

    item = Gwsub::Sb00ConferenceSectionManagerName.new #.readable
    item.search params
    item.and 'sql',"state != 'deleted'"
#    item.and 'sql',"state = 'enabled'"
    item.page   params[:page], params[:limit]
    item.order  @sort_keys , 'markjp desc , g_sort_no , g_code'

    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb00ConferenceSectionManagerName.find(params[:id])
    return http_error(404) if @item.state=='deleted'
  end

  def new
    init_params
    return error_auth unless @u_role==true
    @l1_current='02'

    @item = Gwsub::Sb00ConferenceSectionManagerName.new
    @item.fyear_id=@fyear.to_i
    @item.markjp  = @item.fyear_r.markjp
    @item.state     = 'enabled'
    if @p_gid.to_i==0
      group = System::Group.where(:id => Core.user_group.id).first
    else
      parent_group = System::Group.where(:id => @p_gid).first
      if parent_group.blank?
        group = System::Group.where(:id => Core.user_group.id).first
      else
        g_cond = "state='enabled' and parent_id=#{parent_group.id} and level_no=3"
        g_order = "sort_no"
        group = System::Group.where(g_cond).order(g_order).first
      end
    end
    if group.blank?
      @item.parent_gid  = 0
      @item.gid         = 0
    else
      @item.parent_gid  = group.parent_id
      @item.gid         = group.id
    end
  end
  def create
    init_params
    return error_auth unless @u_role==true
    @l1_current='02'

    @item = Gwsub::Sb00ConferenceSectionManagerName.new(section_manager_params)
    location = @index_uri+"?#{@qs}"
    options = {:success_redirect_uri=>location}
    _create(@item,options)
  end

  def edit
    init_params
    return error_auth unless @u_role==true
    @item = Gwsub::Sb00ConferenceSectionManagerName.find(params[:id])
    return http_error(404) if @item.state=='deleted'
  end

  def update
    init_params
    return error_auth unless @u_role==true
    @item = Gwsub::Sb00ConferenceSectionManagerName.find(params[:id])
    return http_error(404) if @item.state=='deleted'

    @item.attributes = section_manager_params
    location = @index_uri+"?#{@qs}"
    options = {:success_redirect_uri=>location}
    _update(@item,options)
  end

  def destroy
    init_params
    return error_auth unless @u_role==true
    # 論理削除
    @item = Gwsub::Sb00ConferenceSectionManagerName.find(params[:id])
    return http_error(404) if @item.state=='deleted'

    @item.state      = 'deleted'
    @item.deleted_at = Time.new.strftime('%Y-%m-%d %H:%M:%S')
    @item.save(:validate => false)
    flash[:notice] = flash[:notice] || '削除しました。'
    location = @index_uri+"?#{@qs}"
    return redirect_to location
  end

  def init_params
#pp params
#    flash[:notice]=''
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb00ConferenceSectionManagerName.is_dev?
    @role_admin      = Gwsub::Sb00ConferenceSectionManagerName.is_admin?
    @u_role = @role_developer || @role_admin

    # 部局 年度指定なしまたは年度切り替えでは、部局選択を「すべて」に戻す
#    @p_gid   = nz(params['p_gid'],0)
    if params[:pre_fyear_id]
      if params[:pre_fyear_id]==params[:fyear_id]
        @p_gid   = nz(params['p_gid'],0)
      else
        @p_gid   = 0
        params[:p_gid] = 0
      end
    else
        @p_gid   = 0
        params[:p_gid] = 0
        params[:pre_fyear_id] = nz(params['fyear_id'],0)
    end
    # 対象年度
    @fyear  = nz(params['fyear_id'],0)
    # 表示行数　設定
    @limit = nz(params['limit'],30)
    # 検索文字列
    @s_keyword  = params['s_keyword']
    #
    search_condition
    setting_sort_keys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='01'
  end

  def search_condition
    qsa = [ 'limit', 's_keyword' ,'p_gid' , 'fyear_id' , 'pre_fyear_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sort_keys
      @sort_keys = nz(params[:sort_keys], 'markjp DESC , g_sort_no , g_code')
  end

  def synchro
    init_params
    return error_auth unless @u_role==true
    @l1_current='03'
    # system_groups との同期処理
    # 対象年度を設定
    p_order = "target_at DESC"
    #pickup  = System::GroupChangePickup.order(p_order).first
    #if pickup.blank?
      start_at  = Time.now
    #else
    #  start_at = pickup.target_at
    #end
    fyear = Gw::YearFiscalJp.get_record(start_at)
    if fyear.blank?
      flash[:notice] = "同期対象の年度が決まりませんでした。"
      location = @index_uri
      return redirect_to location
    end
    g_cond="state='enabled' and level_no=3"
    g_order = "sort_no"
    groups1 = System::Group.where(g_cond).order(g_order)
    if groups1.blank?
      flash[:notice] = flash[:notice] || '同期対象となる所属が見つかりません。'
      location = @index_uri
      return redirect_to location
    end
    # 登録済を一度すべて下書きにする
#    Gwsub::Sb00ConferenceSectionManagerName.update_all("deleted_at = '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'" , "state!='deleted'")
    Gwsub::Sb00ConferenceSectionManagerName.where("fyear_id=? and state!=?", fyear.id, 'deleted').update_all("state='draft'")
    groups1.each do |g|
      g_cond = "fyear_id=#{fyear.id} and gid=#{g.id} AND state='draft'"
      g_order = "g_sort_no , created_at DESC"
      #g_order = "g_sort_no , created_at ASC"
      items     =   Gwsub::Sb00ConferenceSectionManagerName.where(g_cond).order(g_order)
      if items.blank?
        # なければ新規
        parent_group  = System::Group.where(:id => g.parent_id).first
        if parent_group.blank?
          # 上位部局がなければスキップ
          next
        else
          item      =   Gwsub::Sb00ConferenceSectionManagerName.new
          if parent_group.state == 'enabled'
            item.state        = 'enabled'
          else
            # 上位が無効の場合は、下位も無効
            item.state        = 'disabled'
          end
          item.fyear_id     = fyear.id
          item.markjp       = fyear.markjp
          item.parent_gid   = g.parent_id
          item.gid          = g.id
          item.g_sort_no    = g.sort_no
          item.g_code       = g.code
          item.g_name       = g.name
          item.manager_name = g.name+"長"
          item.deleted_at   = nil
          item.save(:validate => false)
        end
      else
        # 見つかれば再利用
        items.each do |sec|
          item = Gwsub::Sb00ConferenceSectionManagerName.where(:id => sec.id).first
          parent_group  = System::Group.where(:id => g.parent_id).first
          if parent_group.blank?
            # 上位部局がなければスキップ
            next
          else
            if parent_group.state == 'enabled'
              item.state        = 'enabled'
            else
              # 上位が無効の場合は、下位も無効
              item.state        = 'disabled'
            end
            item.deleted_at   = nil
            item.parent_gid   = g.parent_id
  #          item.gid          = g.id
            item.g_sort_no    = g.sort_no
            item.g_code       = g.code
            item.g_name       = g.name
            item.save(:validate => false)
          end
        end
      end
      #item.save(:validate => false)
    end
    #下書きのままのものを削除する
    Gwsub::Sb00ConferenceSectionManagerName.where(:state=>'draft').update_all("state='deleted' , deleted_at='#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'")
    flash[:notice] = flash[:notice] || '同期処理を実行しました。'
    location = @index_uri
    return redirect_to location
  end

  def csvput
    init_params
    @l1_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    items = Gwsub::Sb00ConferenceSectionManagerName
      .where(Gwsub::Sb00ConferenceSectionManagerName.arel_table[:state].not_eq('deleted'))
    items = items.where(fyear_id: @item.extras[:fyear_id]) if @item.extras[:fyear_id] && @item.extras[:fyear_id].to_i != 0
    items = items.order(markjp: :desc, g_sort_no: :asc, g_code: :asc)
    csv = items.to_csv

    filename = "所属長名管理_sb00_#{@item.encoding}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
    send_data @item.encode(csv), filename: filename
  end

  def csvup
    init_params
    @l1_current='05'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].blank?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb00ConferenceSectionManagerName.transaction do
      Gwsub::Sb00ConferenceSectionManagerName.truncate_table
      items = Gwsub::Sb00ConferenceSectionManagerName.from_csv(@item.file_data)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

private

  def section_manager_params
    params.require(:item).permit(:state, :gid, :manager_name)
  end

end
