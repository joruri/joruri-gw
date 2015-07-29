# -*- encoding: utf-8 -*-
class Doclibrary::Admin::GroupFoldersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Doclibrary::Model::DbnameAlias

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    @css = ["/_common/themes/gw/css/doclibrary.css"]
    return http_error(404) unless @title

    Page.title = @title.title

    params[:grp] = 1 if params[:grp].blank?

    item = doclib_db_alias(Doclibrary::GroupFolder)
    if params[:grp].blank? or params[:grp].blank? == '0'
      @parent = item.new({:title_id=>params[:title_id], :id => 0, :level_no => 0})
    else
      @parent = item.find_by_id(params[:grp])
      @parent = item.new({:title_id=>params[:title_id], :id => 0, :level_no => 0}) unless @parent
    end
    @cabinet_title = '書庫'
  end

  def index
    item = doclib_db_alias(Doclibrary::GroupFolder)
    item = item.new

    if @parent.blank?
      item.level_no = 1
    else
      item.parent_id = @parent.id
    end

    item.and  :title_id, params[:title_id]
    item.page  params[:page], params[:limit]
    @items = item.find(:all , :order=>"level_no, sort_no, id")
    Doclibrary::GroupFolder.remove_connection
    _index @items
  end

  def edit
    item = doclib_db_alias(Doclibrary::GroupFolder)
    @item = item.new.find(params[:id],:order =>'sort_no, id')
    Doclibrary::GroupFolder.remove_connection
    return error_auth unless @item
    @parent_state = @item.parent.state if @item.parent
    @parent_state = 'public' if @parent_state.blank?
    _show @item
  end

  def new
    title_id = params[:title_id]
    item = doclib_db_alias(Doclibrary::GroupFolder)
    @item = item.new({
      :state     => 'closed',
      :use_state => 'public',
      :parent_id => @parent.id,
      :title_id  => title_id,
      :sort_no   => 0
    })
    Doclibrary::GroupFolder.remove_connection

    @parent_state = @item.parent.use_state  if @item.parent
    @parent_state = 'public' if @parent_state.blank?
  end

  def create
    item = doclib_db_alias(Doclibrary::GroupFolder)
    @item = item.new(params[:item])
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1

    @item.state = @parent.state if @parent
    @item.state = 'public' if @item.state.blank?
    _create @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def update
    item = doclib_db_alias(Doclibrary::GroupFolder)
    @item = item.new.find(params[:id])
    @item.attributes = params[:item]

    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    @level_items = item.find(:all)
    lower_level_rewrite('update', @level_items, @item.state)
    _update @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def destroy
    item = doclib_db_alias(Doclibrary::GroupFolder)
    @item = item.new.find(params[:id])
    _destroy @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
    Doclibrary::GroupFolder.remove_connection
  end

  def sync_groups
    sync_group_folders
    sync_children
    unless params[:make].blank?
      redirect_to doclibrary_cabinets_path
    else
      redirect_to doclibrary_group_folders_path({:title_id=>@title.id})
    end
  end

  def sync_group_folders
    folder_item = doclib_db_alias(Doclibrary::GroupFolder)
    folder_item.update_all("state = 'closed', use_state = 'closed'", "title_id = #{@title.id}")

    params[:mode] = 'closed' if params[:mode].blank?
    grp = Gwboard::Group.new
    grp.and :state, 'enabled'
    groups = grp.find(:all , :order=>"level_no, sort_no, id")
    for group in groups
      folder = folder_item.new
      folder.and :title_id, @title.id
      folder.and :code, group.code
      folder = folder.find(:first)
      s_state = params[:mode]
      s_state = 'closed' if group.ldap == 0

      unless folder.blank?
        folder_item.update(folder.id,
          :state => s_state,
          :use_state => s_state,
          :updated_at => Time.now,
          :parent_id => get_sync_parent_id(folder_item, group.parent_id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id
        )
      else
        add_folder = folder_item.new(
          :state => s_state,
          :use_state => s_state,
          :title_id => @title.id,
          :parent_id => get_sync_parent_id(folder_item, group.parent_id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :children_size => 0,
          :total_children_size =>0,
          :code => group.code,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id
        )
        add_folder.save!
      end
    end

    folder_item.update_all("state = 'public'", "title_id = #{@title.id} and level_no = 1")

    section_folder_state_update

    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.update_group_folder_children_size

    Doclibrary::Doc.remove_connection
    Doclibrary::GroupFolder.remove_connection
  end

  def sync_children
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.update_group_folder_children_size
  end

  def get_sync_parent_id(folder_item, parent_id)
    ret = nil
    folder = folder_item.new
    folder.and :title_id, params[:title_id]
    folder.and :sysgroup_id, parent_id
    folder = folder.find(:first)
    ret = folder.id if folder
    return ret
  end

  def lower_level_rewrite(mode, items, state)
    if items.size > 0
      items.each do |item|
        level_item = doclib_db_alias(Doclibrary::GroupFolder)
        level_item.update(item.id, :state =>'closed') unless mode == 'sync' if state =='closed'#
        if item.children.size > 0
            lower_level_rewrite(mode, item.children, state)
        end
      end
    end
  end

  def section_folder_state_update
    group_item = doclib_db_alias(Doclibrary::GroupFolder)
    item = doclib_db_alias(Doclibrary::Doc)
    item = item.new
    item.and :state, 'public'
    item.and :title_id, params[:title_id]
    item.find(:all, :select=>'section_code', :group => 'section_code').each do |code|
      g_item = group_item.new
      g_item.and :title_id, params[:title_id]
      g_item.and :code, code.section_code
      g_item.find(:all).each do |group|
        group_state_rewrite(group,group_item)
      end
    end

  end

  def group_state_rewrite(item, group_item)
    group_item.update(item.id, :state =>'public')
    unless item.parent.blank?
      group_state_rewrite(item.parent, group_item)
    end
  end
end
