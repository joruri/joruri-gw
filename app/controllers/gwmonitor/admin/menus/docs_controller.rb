# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::Menus::DocsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @title_id = params[:title_id]
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find_by_id(@title_id)
    return http_error(404) unless @title
    page_limit_default_setting
  end

  def is_permission
    ret = false
    ret = true if @item.section_code == Site.user_group.code if @item.send_division == 1
    ret = true if @item.user_code == Site.user.code if @item.send_division == 2
    return ret
  end

  def index
    redirect_to '/gwmonitor'
  end

  def show
    @item = Gwmonitor::Doc.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_permission
    return if @title.spec_config < 3

    sql = Condition.new

    sql.or {|d|
      d.and :state , '!=', 'preparation'
      d.and :title_id, @title.id
      d.and :send_division , 2
      d.and :user_code, '!=', Site.user.code
    }

    sql.or {|d|
      d.and :state , '!=', 'preparation'
      d.and :title_id, @title.id
      d.and :send_division , 1
      d.and :section_code , '!=', Site.user_group.code
    }
    item = Gwmonitor::Doc.new
    item.order 'state, section_sort'
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :conditions=>sql.where)
  end

  def edit
    @item = Gwmonitor::Doc.find_by_id(params[:id])
    return http_error(404) unless @item
    @is_editable = is_permission
    return authentication_error(403) unless @is_editable unless @title.spec_config ==5

    attach_dsp = false
    if @title.spec_config == 5
      attach_dsp = true
    end unless @is_editable
    attach_dsp = true if @title.state == 'closed' #締切りの時は詳細表示のみにする
    if attach_dsp
      item = Gwmonitor::File.new
      item.and :title_id , @title.id
      item.and :parent_id , @item.id
      @files = item.find(:all)
    end
  end

  def new
    redirect_to '/gwmonitor'
  end

  def update
    @item = Gwmonitor::Doc.find(params[:id])
    return authentication_error(403) unless is_permission

    @item.attributes = params[:item]

    @item.latest_updated_at = Time.now

    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code
    @item.editor = Site.user.name
    @item.editordivision = Site.user_group.name
    @item.editordivision_id = Site.user_group.code

    location = @item.show_path
    _update(@item,:success_redirect_uri=>location)
  end

  def editing_state_setting
    @item = Gwmonitor::Doc.find(params[:id]);
    return authentication_error(403) unless is_permission

    @item.latest_updated_at = Time.now

    @item.state = 'editing'
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code
    @item.editor = Site.user.name
    @item.editordivision = Site.user_group.name
    @item.editordivision_id = Site.user_group.code

    location = @item.show_path
    _update(@item,:success_redirect_uri=>location)
  end

  def draft_state_setting
    @item = Gwmonitor::Doc.find(params[:id])
    return authentication_error(403) unless is_permission

    @item.latest_updated_at = Time.now

    @item.state = 'draft'
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code
    @item.editor = Site.user.name
    @item.editordivision = Site.user_group.name
    @item.editordivision_id = Site.user_group.code

    location = @item.show_path
    _update(@item,:success_redirect_uri=>location)
  end

  def clone
    @item = Gwmonitor::Doc.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_permission

    clone_doc(@title,{:location=>@item.show_path})

  end

end
