# -*- encoding: utf-8 -*-
class Digitallibrary::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Digitallibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/digitallibrary.css"]
    Page.title = "電子図書"
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
    item = Digitallibrary::Control.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, docslast_updated_at DESC, updated_at DESC')
  end

  def readable_index

    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "digitallibrary_roles.role_code = 'r'"
      d.and "sql", "digitallibrary_roles.group_code = '0'"
    }

    for group in Site.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        d.and "sql", "digitallibrary_roles.role_code = 'r'"
        d.and "sql", "digitallibrary_roles.group_code = '#{group.code}'"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          d.and "sql", "digitallibrary_roles.role_code = 'r'"
          d.and "sql", "digitallibrary_roles.group_code = '#{group.parent.code}'"
        }
      end

      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        d.and "sql", "digitallibrary_roles.role_code = 'r'"
        d.and "sql", "digitallibrary_roles.user_code = '#{Site.user.code}'"
      }
    end
    join = "INNER JOIN digitallibrary_roles ON digitallibrary_controls.id = digitallibrary_roles.title_id"
    item = Digitallibrary::Control.new
    item.page   params[:page], params[:limit]
    menu_order = "sort_no , docslast_updated_at DESC "
    @items = item.find(:all, :joins=>join, :conditions=>sql.where,:order => menu_order, :group => 'digitallibrary_controls.id')
  end
end
