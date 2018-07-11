class Gwsub::Admin::Sb00::Sb00ConferenceReferencesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "申請書表示設定"

    index_path = @index_uri
    return redirect_to(index_path) if params[:reset]
  end

  def index
    init_params
    item = Gwsub::Sb00ConferenceReference.new #.readable
    item.search params
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'

    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Sb00ConferenceReference.find(params[:id])
  end

  def new
    init_params
    unless params[:l2_c]
      @l2_current ='02'
    end
    unless params[:l3_c]
      @l3_current ='02'
    end
    unless params[:l4_c]
      @l4_current ='02'
    end
    comm_params = "?h1_menu=#{@render_menu1}&h2_menu=#{@render_menu2}&h3_menu=#{@render_menu3}&ctrl=#{@ctrl}&l1_c=#{@l1_current}"
    comm_params << "&u_role=#{@u_role}"
    comm_params << "&ctrl=#{@ctrl}"
    comm_params << "&l1_c=#{@l1_current}"
    comm_params << "&l2_c=#{@l2_current}"     unless @l2_current.blank?
    comm_params << "&l3_c=#{@l3_current}"     unless @l3_current.blank?
    comm_params << "&ctrl_name=#{@ctrl_name}" unless @ctrl_name.blank?
    if @ctrl_name=="sb06_assigned_conferences"
      comm_params << "&fy_id=#{@fy_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}&help=#{@help}"
    end
    location = @index_uri+comm_params
    if params[:do]=='copy'
      # コピー元取得
      item = Gwsub::Sb00ConferenceReference.new
      item.and :fyear_id , @copy_fyear_id
      item.and :group_id , Core.user_group.id
      item.order "kind_code"
      items = item.find(:all)
      # コピー先年度取得
      if @copy_fyear_id.to_i==0
        current_fyear = Gw::YearFiscalJp.get_record(Time.now)
      else
        current_fyear =Gw::YearFiscalJp.find(@copy_fyear_id)
      end
      next_fyear = Gw::YearFiscalJp.get_next_year_record(current_fyear.start_at)
#      next_fyear = Gw::YearFiscalJp.get_next_year_record(Time.now)
      if next_fyear.blank?
        flash[:notice] = "コピー先年度が登録されていません。"
        redirect_to location
        return
      end
      # コピー先データ取得
      item = Gwsub::Sb00ConferenceReference.new
      item.and :fyear_id , next_fyear.id
      item.and :group_id , Core.user_group.id
      item.order "kind_code"
      items_del = item.find(:all)
      unless items_del.blank?
        Gwsub::Sb00ConferenceReference.destroy_all("fyear_id = #{next_fyear.id} and group_id=#{Core.user_group.id}")
#        flash[:notice] = "コピー済です。"
#        redirect_to location
#        return
      end
      Gwsub::Sb00ConferenceReference.transaction do
        # コピー
        begin
          items.each do |item1|
            item_new = Gwsub::Sb00ConferenceReference.new
            item_new.fyear_id     = next_fyear.id
            item_new.fyear_markjp = next_fyear.markjp
            item_new.kind_code    = item1.kind_code
            item_new.kind_name    = item1.kind_name
            item_new.title        = item1.title
            item_new.group_id     = item1.group_id
            item_new.save!
          end
        rescue
          next
        end
      end
      flash[:notice] = "次年度分をコピーで登録しました。"
      redirect_to location
      return
    else
      @item = Gwsub::Sb00ConferenceReference.new
    end
  end
  def create
    init_params
    unless params[:l2_c]
      @l2_current ='02'
    end
    unless params[:l3_c]
      @l3_current ='02'
    end
    unless params[:l4_c]
      @l4_current ='02'
    end
    @item = Gwsub::Sb00ConferenceReference.new(reference_params)
    comm_params = "?h1_menu=#{@render_menu1}&h2_menu=#{@render_menu2}&h3_menu=#{@render_menu3}&ctrl=#{@ctrl}&l1_c=#{@l1_current}"
    comm_params << "&u_role=#{@u_role}"
    comm_params << "&ctrl=#{@ctrl}"
    comm_params << "&l1_c=#{@l1_current}"
    comm_params << "&l2_c=#{@l2_current}"     unless @l2_current.blank?
    comm_params << "&l3_c=#{@l3_current}"     unless @l3_current.blank?
    comm_params << "&ctrl_name=#{@ctrl_name}" unless @ctrl_name.blank?
    if @ctrl_name=="sb06_assigned_conferences"
      comm_params << "&fy_id=#{@fy_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}&help=#{@help}"
    end
    location = @index_uri+comm_params
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb00ConferenceReference.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb00ConferenceReference.find(params[:id])
    @item.attributes = reference_params
    comm_params = "?h1_menu=#{@render_menu1}&h2_menu=#{@render_menu2}&h3_menu=#{@render_menu3}&ctrl=#{@ctrl}&l1_c=#{@l1_current}"
    comm_params << "&u_role=#{@u_role}"
    comm_params << "&ctrl=#{@ctrl}"
    comm_params << "&l1_c=#{@l1_current}"
    comm_params << "&l2_c=#{@l2_current}"     unless @l2_current.blank?
    comm_params << "&l3_c=#{@l3_current}"     unless @l3_current.blank?
    comm_params << "&ctrl_name=#{@ctrl_name}" unless @ctrl_name.blank?
    if @ctrl_name=="sb06_assigned_conferences"
      comm_params << "&fy_id=#{@fy_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}&help=#{@help}"
    end
    location = "#{@index_uri}#{@item.id}#{comm_params}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb00ConferenceReference.find(params[:id])
    comm_params = "?h1_menu=#{@render_menu1}&h2_menu=#{@render_menu2}&h3_menu=#{@render_menu3}&ctrl=#{@ctrl}&l1_c=#{@l1_current}"
    comm_params << "&u_role=#{@u_role}"
    comm_params << "&ctrl=#{@ctrl}"
    comm_params << "&l1_c=#{@l1_current}"
    comm_params << "&l2_c=#{@l2_current}"     unless @l2_current.blank?
    comm_params << "&l3_c=#{@l3_current}"     unless @l3_current.blank?
    comm_params << "&ctrl_name=#{@ctrl_name}" unless @ctrl_name.blank?
    if @ctrl_name=="sb06_assigned_conferences"
      comm_params << "&fy_id=#{@fy_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}&help=#{@help}"
    end
    location = @index_uri+comm_params
    options = {
      :success_redirect_uri=>location,
    }
    _destroy(@item,options)
  end

  def init_params
#pp params
    #    flash[:notice]=''
    # ユーザー権限設定
#    @role_developer  = Gwsub::Sb00ConferenceReference.is_dev?
#    @role_admin      = Gwsub::Sb00ConferenceReference.is_admin?
#    @u_role = @role_developer || @role_admin

    if params[:u_role]=='true'
      @u_role = true
    else
      @u_role = false
    end

    # 年度
    @fy = Gw::YearFiscalJp.get_record(Date.today)
    if @fy.blank?
      @fy = Gw::YearFiscalJp.order("start_at DESC").first
    end
    @fy_id = @fy.id
    # コピー元id 設定
    if params[:do]=="copy"
      @copy_fyear_id = 0
#      fyear = Gw::YearFiscalJp.get_record(Date.today)
#      @copy_fyear_id = fyear.id unless fyear.blank?
      # 最終登録年度を取得し、その翌年度を設定
      ref_cond  = "group_id=#{Core.user_group.id}"
      ref_order = "fyear_markjp DESC"
      max_fyear = Gwsub::Sb00ConferenceReference.where(ref_cond).order(ref_order).first
      @copy_fyear_id  = max_fyear.fyear_id unless max_fyear.blank?
    end
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    # level1 表示メニュー設定
    @render_menu1 = nz(params[:h1_menu],nil)
    # level2 表示メニュー設定
    @render_menu2 = nz(params[:h2_menu],nil)
    # 戻り先設定
    @r_uri = nz(params[:r_uri],@index_uri)

    # 呼び出し元解析
    @ctrl_name  = params[:ctrl_name]
    case params[:ctrl_name]
    when "sb06_assigned_conferences"
      @c_cat_id   = params[:c_cat_id]
      @kind_id    = params[:kind_id]
      @help       = params[:help]
    else
    end
    # 適用クラス
    @comm_class = @ctrl_name.split('_') if @ctrl_name
    @comm_class_no = @comm_class[0] if @comm_class
    @ctrl_title   = Gwsub::Sb00ConferenceManager.ctrl_show(@ctrl_name)

    search_condition
    setting_sort_keys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current=nz(params[:l1_c],'01')
    @l2_current=nz(params[:l2_c],nil)
    if @l2_current.blank?
      @l3_current='01'
    else
      @l3_current=nz(params[:l3_c],nil)
    end
    if @l3_current.blank?
      @l4_current='01'
    else
      @l4_current=nz(params[:l4_c],'01')
    end

    # 表示用ヘッダ
    if params[:piece_header]
      @piece_header = params[:piece_header]
    else
      @piece_header = '申請書表示設定'
    end
  end

  def search_condition
#    qsa = [ 'h1_menu','h2_menu','r_uri', 'limit', 's_keyword' , 'kind_code']
#    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sort_keys
      @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC, kind_code ASC')
  end

private

  def reference_params
    params.require(:item).permit(:kind_code, :kind_name, :fyear_id, :title, :group_id)
  end

end
