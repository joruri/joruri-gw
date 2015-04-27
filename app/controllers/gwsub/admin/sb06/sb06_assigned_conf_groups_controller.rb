class Gwsub::Admin::Sb06::Sb06AssignedConfGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "20申請書管理所属"
    init_params
    return error_auth unless @u_role == true
  end

  def index

#    pp params
    item = Gwsub::Sb06AssignedConfGroup.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show

    @item = Gwsub::Sb06AssignedConfGroup.find(params[:id])
  end

  def new

    @l3_current='02'
    @item = Gwsub::Sb06AssignedConfGroup.new
  end
  def create

    @l3_current='02'
    @item = Gwsub::Sb06AssignedConfGroup.new(params[:item])
    location = url_for({:action => :index})
    _create(@item,:success_redirect_uri=>location)
  end

  def edit

    @item = Gwsub::Sb06AssignedConfGroup.find(params[:id])
    @cat_id = @item.categories_id
  end
  def update

    @item = Gwsub::Sb06AssignedConfGroup.new.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :index})
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    @item = Gwsub::Sb06AssignedConfGroup.new.find(params[:id])
    location = url_for({:action => :index})
    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    @l3_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb06AssignedConfGroup.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb06_assigned_conf_groups_#{@item.encoding}.csv"
  end

  def csvup
    @l3_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb06AssignedConfGroup.transaction do
      Gwsub::Sb06AssignedConfGroup.truncate_table
      items = Gwsub::Sb06AssignedConfGroup.from_csv(@item.file_data, i18n_key: :default)
      items.each(&:save)
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to action: :index
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb0606menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_assigned_conf_groups'
    @menu_title4  = '申請書管理所属'
    # 分類設定
    cat_1 =Gwsub::Sb06AssignedConfCategory.order("cat_sort_no").first
    if cat_1.blank?
      @cat_id  = nz(params[:cat_id],0)
    else
      @cat_id  = nz(params[:cat_id],cat_1.id)
    end
    # 年度設定
    current_fyear =Gw::YearFiscalJp.get_record(Time.now)
    if current_fyear.blank?
      @fy_id  = nz(params[:fy_id],0)
    else
      @fy_id  = nz(params[:fy_id],current_fyear.id)
    end
    # 所属設定
    c_group_conditions  = "categories_id=#{@cat_id}"
    c_group_order = "cat_sort_no , fyear_markjp DESC"
    c_group = Gwsub::Sb06AssignedConfGroup.order(c_group_order).where(c_group_conditions).first
    if c_group.blank?
      @c_group_id  = nz(params[:c_group_id],0)
    else
      @c_group_id  = nz(params[:c_group_id],c_group.id)
    end
    # 表示行数　設定
    @limit  = nz(params[:limit],30)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='04'
    @l2_current='01'
    @l3_current='01'

    return
  end
  def search_condition
    params[:cat_id]     = nz(params[:cat_id], @cat_id)
    params[:fy_id]      = nz(params[:fy_id], @fy_id)
    params[:c_group_id] = nz(params[:c_group_id], @c_group_id)
    params[:limit]      = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword' , 'cat_id','fy_id','c_group_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
#    @sort_keys = nz(params[:sort_keys], 'fyear_id DESC , group_code ASC')
    @sort_keys = nz(params[:sort_keys], 'cat_sort_no , fyear_markjp DESC ')
  end

end
