# encoding: utf-8
class Gwbbs::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "掲示板"
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    admin_flags('_menu')
    if @is_sysadm
      admin_index
    else
      readable_index
    end
  end

  def admin_index
    item = Gwbbs::Control.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, docslast_updated_at DESC')
  end

  def readable_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwbbs_roles.role_code = 'r'"
      d.and "sql", "gwbbs_roles.group_code = '0'"
    }
    for group in Site.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        d.and "sql", "gwbbs_roles.role_code = 'r'"
        d.and "sql", "gwbbs_roles.group_code = '#{group.code}'"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          d.and "sql", "gwbbs_roles.role_code = 'r'"
          d.and "sql", "gwbbs_roles.group_code = '#{group.parent.code}'"
        }
      end
    end

    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwbbs_roles.role_code = 'r'"
      d.and "sql", "gwbbs_roles.user_code = '#{Site.user.code}'"
    }
    join = "INNER JOIN gwbbs_roles ON gwbbs_controls.id = gwbbs_roles.title_id"
    item = Gwbbs::Control.new
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :joins=>join, :conditions=>sql.where,:order => 'sort_no, docslast_updated_at DESC', :group => 'gwbbs_controls.id')
  end
end
