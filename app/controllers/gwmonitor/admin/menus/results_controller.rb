# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::Menus::ResultsController < Gw::Controller::Admin::Base

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

  def is_admin
    system_admin_flags
    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return authentication_error(403) unless is_admin
    sql = Condition.new
    if params[:cond] == 'unanswered'
      sql.or {|d|
        d.and :state , 'draft'
        d.and :title_id, @title.id
      }
      sql.or {|d|
        d.and :state , 'closed'
        d.and :title_id, @title.id
      }
      sql.or {|d|
        d.and :state , 'editing'
        d.and :title_id, @title.id
      }
    end
    unless params[:cond] == 'unanswered'
      sql.or {|d|
        d.and :state , '!=', 'preparation'
        d.and :title_id, @title.id
      }
    end
    item = Gwmonitor::Doc.new
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :conditions=>sql.where, :order=>'state, section_sort')
  end

  def show
    return authentication_error(403) unless is_admin
    @item = Gwmonitor::Doc.find_by_id(params[:id])
    return http_error(404) unless @item

    item = Gwmonitor::File.new
    item.and :title_id , @title.id
    item.and :parent_id , @item.id
    @files = item.find(:all)

  end

  def edit
    return authentication_error(403) unless is_admin
    @item = Gwmonitor::Doc.find_by_id(params[:id])
    return http_error(404) unless @item

    item = Gwmonitor::File.new
    item.and :title_id , @title.id
    item.and :parent_id , @item.id
    @files = item.find(:all)
  end

  def new
    redirect_to "/gwmonitor/#{@title.id}/results"
  end

  def update
    return authentication_error(403) unless is_admin
    @item = Gwmonitor::Doc.find(params[:id])
    return http_error(404) unless @item

    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.note = "#{@item.note}#{Time.now.strftime("%Y-%m-%d %H:%M")}:#{Site.user.name}によって回答が更新されました。\n"

    location = "/gwmonitor/#{@title.id}/results"
    _update(@item,:success_redirect_uri=>location)
  end


end
