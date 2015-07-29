# encoding: utf-8
class Gw::Admin::EditTabsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    Page.title = "タブ編集"
  end

  def index
    init_params
    return authentication_error(403) unless @u_role==true

    item = Gw::EditTab.new
    item.page  params[:page], params[:limit]
    cond  = "state!='deleted' and parent_id=#{@parent.id}"
    order = "sort_no"
    @items = item.find(:all,:order=>order,:conditions=>cond)
    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role==true

    @item = Gw::EditTab.find_by_id(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @u_role==true

    cond  = "state!='deleted' and parent_id=#{@parent.id}"
    order = "sort_no DESC"
    max_sort = Gw::EditTab.find(:first , :order=>order , :conditions=>cond)
    if max_sort.blank?
      max_sort_no = 0
    else
      max_sort_no = max_sort.sort_no
    end
    @item = Gw::EditTab.new
    @item.parent_id       = @parent.id
    @item.level_no        = @parent.level_no + 1
    @item.state           = 'enabled'
    @item.published       = 'opened'
    @item.tab_keys        = 0
    @item.sort_no         = max_sort_no.to_i + 10
    @item.class_created   = 1
    @item.class_external  = 0
    @item.class_sso       = 1
    @item.is_public       = 0
  end

  def create
    init_params
    return authentication_error(403) unless @u_role==true
    @item = Gw::EditTab.new

    if @item.save_with_rels params, :create
      flash_notice '更新', true
      redirect_to url_for(:action => :show, :id => @item.id, :pid => @parent.id)
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def edit
    init_params
    return authentication_error(403) unless @u_role==true

    @item = Gw::EditTab.find_by_id(params[:id])

    public_groups = Array.new
    gids = Array.new

    @item.public_roles.each do |public_role|
      if public_role.class_id == 2
        gids << public_role.uid
      end
    end

    parent_groups = System::GroupHistory.new.find(:all, :conditions =>"level_no = 2", :order=>"sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    groups = System::GroupHistory.new.find(:all, :conditions => ["id in (?)", gids], :order=>"level_no, sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")

    parent_groups.each do |parent_group|
      groups.each do |group|
        name = Gw.trim(group.name)
        g = System::Group.find_by_id(group.id)
        if !g.blank?
          if g.id == parent_group.id
            public_groups.push ["", group.id, name]
          elsif g.parent_id == parent_group.id
            if g.state == "disabled"

            else
              public_groups.push ["", group.id, name]
            end
          end
        end
      end
    end

    @public_groups_json = public_groups.to_json

  end
  def update
    init_params

    @item = Gw::EditTab.find_by_id(params[:id])

    if @item.save_with_rels params, :update
      flash_notice '更新', true
      redirect_to url_for(:action => :show, :id => @item.id, :pid => @parent.id)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    init_params

    item = Gw::EditTab.find_by_id(params[:id])
    item.published      = 'closed'
    item.state          = 'deleted'
    item.tab_keys       = nil
    item.sort_no        = nil
    item.deleted_at     = Time.now
    item.deleted_user   = @user.name
    item.deleted_group  = @group.name
    item.save(:validate => false)

    flash[:notice] = "削除処理が完了しました。"
    redirect_to url_for(:action => :index, :pid => @parent.id)
  end

  def updown
    init_params
    return authentication_error(403) unless @u_role==true

    item = Gw::EditTab.find_by_id(params[:id])
    if item.blank?
      redirect_to url_for(:action => :index, :pid => @parent.id)
      return
    end

    updown = params[:order]

    case updown
    when 'up'
      cond  = "state!='deleted' and parent_id=#{@parent.id} and sort_no < #{item.sort_no} "
      order = " sort_no DESC "
      item_rep = Gw::EditTab.find(:first,:conditions=>cond,:order=>order)
      if item_rep.blank?
      else
        sort_work = item_rep.sort_no
        item_rep.sort_no = item.sort_no
        item.sort_no = sort_work
        item.save(:validate => false)
        item_rep.save(:validate => false)
      end
    when 'down'
      cond  = "state!='deleted' and parent_id=#{@parent.id} and sort_no > #{item.sort_no} "
      order = " sort_no ASC "
      item_rep = Gw::EditTab.find(:first,:conditions=>cond,:order=>order)
      if item_rep.blank?
      else
        sort_work = item_rep.sort_no
        item_rep.sort_no = item.sort_no
        item.sort_no = sort_work
        item.save(:validate => false)
        item_rep.save(:validate => false)
      end
    else
    end

   redirect_to url_for(:action => :index, :pid => @parent.id)
    return
  end

  def list
    init_params
    return authentication_error(403) unless @u_role==true

    item = Gw::EditTab.new
    cond  = "state!='deleted' and level_no=2"
    order = "state DESC,sort_no"
    @items = item.find(:all,:order=>order,:conditions=>cond)
  end

  def init_params
    @role_developer = Gw::EditTab.is_dev?(Site.user.id)
    @role_admin     = Gw::EditTab.is_admin?(Site.user.id)
    @role_editor  = Gw::EditTab.is_editor?(Site.user.id)
    @u_role = @role_developer || @role_admin || @role_editor

    pid      = params[:pid] == '0' ? 1 : params[:pid]
    @parent = Gw::EditTab.find_by_id(pid)

    @user = Site.user
    @group = Site.user_group

    params[:limit] = nz(params[:limit],30)
  end
end
