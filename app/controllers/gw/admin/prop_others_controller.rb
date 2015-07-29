# encoding: utf-8
class Gw::Admin::PropOthersController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def initialize_scaffold
    super
    @genre = 'other'
    @model = Gw::PropOther
    @model_image = Gw::PropOtherImage
    @uri_base = '/gw/prop_others'
    @item_name = '一般施設'
    Page.title = "一般施設マスタ"
    @prop_types = Gw::PropType.find(:all, :conditions => ["state = ?", "public"], :select => "id, name", :order => 'sort_no, id')
  end

  def get_index_items
    @s_admin_group = Gw::PropOtherRole.get_search_select("admin", @is_gw_admin)
  end

  def index
    init_params
    get_index_items
    item = @model.new
    item.page  params[:page], params[:limit]

    @s_type_id = nz(params[:s_type_id], "0").to_i
    @s_admin_gid = nz(params[:s_admin_gid], "0").to_i

    cond = "delete_state = 0"
    cond += " and type_id = #{@s_type_id}" if @s_type_id != 0

    if @s_admin_gid != 0 && @is_gw_admin
      cond_other_admin = ""
      s_other_admin_group = System::GroupHistory.find_by_id(@s_admin_gid)
      s_other_admin_group
      cond_other_admin = "  "
      if s_other_admin_group.level_no == 2
        gids = Array.new
        gids << @s_admin_gid
        parent_groups = System::GroupHistory.new.find(:all, :conditions => ['parent_id = ?', @s_admin_gid])
        parent_groups.each do |parent_group|
          gids << parent_group.id
        end
        search_group_ids = Gw.join([gids], ',')
        cond_other_admin += " and (auth = 'admin' and  gw_prop_other_roles.gid in (#{search_group_ids}))"
      else
        cond_other_admin += " and (auth = 'admin' and  gw_prop_other_roles.gid = #{s_other_admin_group.id})"
      end
      cond += cond_other_admin
    elsif !@is_gw_admin
      cond += " and auth = 'admin' and ((gw_prop_other_roles.gid = #{Site.user_group.id}) or (gw_prop_other_roles.gid = 0))" if !@is_gw_admin
    end

    @items = item.find(:all, :conditions=>cond,
            :joins => :prop_other_roles, :group => "prop_id")

    parent_groups = Gw::PropOther.get_parent_groups

    @items.sort!{|a, b|
        ag = System::GroupHistory.find_by_id(a.get_admin_first_id(parent_groups))
        bg = System::GroupHistory.find_by_id(b.get_admin_first_id(parent_groups))
        flg = (!ag.blank? && !bg.blank?) ? ag.sort_no <=> bg.sort_no : 0
        (b.reserved_state <=> a.reserved_state).nonzero? or (a.type_id <=> b.type_id).nonzero? or (flg).nonzero? or a.sort_no <=> b.sort_no
    }
  end

  def new
    init_params
    @item = @model.new({})

    json = []
    json.push ["", @group.id, @group.name]
    json = json.to_json
    @admin_json = json
    @editors_json = json
    @readers_json = []
  end

  def show
    init_params
    @item = @model.find(params[:id])

    if @item.delete_state == 1
      if @genre == 'other'
        raise 'この施設は削除されています。'
      end
    end

    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
  end

  def create
    init_params
    raise '管理者権限がありません。' if !@is_admin
    @item = @model.new()

    if @item.save_with_rels params, :create
      flash_notice '一般設備の登録', true
      redirect_to "#{@uri_base}?cls=#{@cls}"
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    init_params
    raise '管理者権限がありません。' if !@is_admin
    @item = @model.find(params[:id])
    if @item.save_with_rels params, :update
      flash_notice '一般設備の編集', true
      redirect_to "#{@uri_base}?cls=#{@cls}"
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    init_params
    parent_groups = Gw::PropOther.get_parent_groups

    @item = @model.find(params[:id])
    raise '管理者権限がありません。' if !@is_admin

    @admin_json = @item.admin(:select, parent_groups).to_json
    @editors_json = @item.editor(:select, parent_groups).to_json
    @readers_json = @item.reader(:select, parent_groups).to_json
  end
end
