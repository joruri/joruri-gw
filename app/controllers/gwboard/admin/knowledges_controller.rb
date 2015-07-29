# -*- encoding: utf-8 -*-
class Gwboard::Admin::KnowledgesController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Model::KbdbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/gwfaq.css", "/_common/themes/gw/css/gwqa.css"]
    Page.title = "質問管理"
  end

  def index
    faq_index
    qa_index
  end

  def faq_index
    faq_admin_flags('_menu')
    @is_faq_admin = @is_admin
    if @is_sysadm
      faq_admin_index
    else
      faq_readable_index
    end
  end

  def faq_admin_index
    item = Gwfaq::Control.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.page params[:page], params[:limit]
    @faq_items = item.find(:all, :order => 'sort_no , docslast_updated_at DESC')
  end

  def faq_readable_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwfaq_roles.role_code = 'r'"
      d.and "sql", "gwfaq_roles.group_code = '0'"
    }

    for group in Site.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        d.and "sql", "gwfaq_roles.role_code = 'r'"
        d.and "sql", "gwfaq_roles.group_code = '#{group.code}'"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          d.and "sql", "gwfaq_roles.role_code = 'r'"
          d.and "sql", "gwfaq_roles.group_code = '#{group.parent.code}'"
        }
      end
    end

    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwfaq_roles.role_code = 'r'"
      d.and "sql", "gwfaq_roles.user_code = '#{Site.user.code}'"
    }
    join = "INNER JOIN gwfaq_roles ON gwfaq_controls.id = gwfaq_roles.title_id"
    item = Gwfaq::Control.new
    item.page   params[:page], params[:limit]
    menu_order = "sort_no , docslast_updated_at DESC "
    @faq_items = item.find(:all, :joins=>join, :conditions=>sql.where,:order => menu_order, :group => 'gwfaq_controls.id')
  end

  def qa_index
    qa_admin_flags('_menu')
    @is_qa_admin = @is_admin
    if @is_sysadm
      qa_admin_index
    else
      qa_readable_index
    end
  end

  def qa_admin_index
    item = Gwqa::Control.new
    item.and :state, 'public'
    item.and :view_hide , 1
    item.page params[:page], params[:limit]
    @qa_items = item.find(:all, :order => 'sort_no , docslast_updated_at DESC')
  end

   def qa_readable_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwqa_roles.role_code = 'r'"
      d.and "sql", "gwqa_roles.group_code = '0'"
    }

    for group in Site.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        d.and "sql", "gwqa_roles.role_code = 'r'"
        d.and "sql", "gwqa_roles.group_code = '#{group.code}'"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          d.and "sql", "gwqa_roles.role_code = 'r'"
          d.and "sql", "gwqa_roles.group_code = '#{group.parent.code}'"
        }
      end
    end

    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      d.and "sql", "gwqa_roles.role_code = 'r'"
      d.and "sql", "gwqa_roles.user_code = '#{Site.user.code}'"
    }
    join = "INNER JOIN gwqa_roles ON gwqa_controls.id = gwqa_roles.title_id"

    item = Gwqa::Control.new
    item.page   params[:page], params[:limit]
    menu_order = "sort_no , docslast_updated_at DESC "
    @qa_items = item.find(:all, :joins=>join, :conditions=>sql.where,:order => menu_order, :group => 'gwqa_controls.id')
  end
end
