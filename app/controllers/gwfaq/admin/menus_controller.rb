# -*- encoding: utf-8 -*-
class Gwfaq::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwfaq::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
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
    item = Gwfaq::Control.new
    item.and :state, 'public'
    item.and :view_hide , 1
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no , docslast_updated_at DESC')
  end

  def readable_index
    parent_group_codes = Site.user_group.parent_tree.map{|g| g.code}
    
    item = Gwfaq::Control.new
    item.and :state, 'public'
    item.and :view_hide, 1
    item.and do |d|
      d.or do |d2|
        d2.and "gwfaq_adms.user_id", 0
        d2.and "gwfaq_adms.group_code", parent_group_codes
      end
      d.or do |d2|
        d2.and "gwfaq_adms.user_code", Site.user.code
        d2.and "gwfaq_adms.group_code", Site.user_group.code
      end
      d.or do |d2|
        d2.and "gwfaq_roles.role_code", ['r', 'w']
        d2.and "gwfaq_roles.group_code", '0'
      end
      d.or do |d2|
        d2.and "gwfaq_roles.role_code", ['r', 'w']
        d2.and "gwfaq_roles.group_code", parent_group_codes
      end
      d.or do |d2|
        d2.and "gwfaq_roles.role_code", ['r', 'w']
        d2.and "gwfaq_roles.user_code", Site.user.code
      end
    end
    item.join "LEFT JOIN gwfaq_adms  ON gwfaq_controls.id = gwfaq_adms.title_id"
    item.join "LEFT JOIN gwfaq_roles ON gwfaq_controls.id = gwfaq_roles.title_id"
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => "sort_no, docslast_updated_at DESC", :group => 'gwfaq_controls.id')
  end
end
