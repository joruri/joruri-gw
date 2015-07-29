# -*- encoding: utf-8 -*-
class Gwboard::Admin::KnowledgeMakersController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Model::KbdbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def initialize_scaffold
     @system = 'gwfaq'
     @css = ["/_common/themes/gw/css/gwfaq.css"]
      Page.title = "質問管理"
  end

  def index
    faq_index
    qa_index
    return http_error(403) if !@is_faq_admin && !@is_qa_admin
  end

  def faq_index
    faq_admin_flags('_menu')
    @is_faq_admin = @is_admin
    if @is_sysadm
      faq_sysadm_index
    else
      faq_bbsadm_index
    end
  end

  def faq_sysadm_index
    item = Gwfaq::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.page params[:page], params[:limit]
    @faq_items = item.find(:all, :order => 'sort_no, updated_at DESC')
  end

  def faq_bbsadm_index
    item = Gwfaq::Control.new
    item.and "gwfaq_controls.state", 'public'
    item.and "gwfaq_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "gwfaq_adms.user_code", Core.user.code
      end
      d.or do |d2|
        d2.and "gwfaq_adms.user_id", 0
        d2.and "gwfaq_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN gwfaq_adms ON gwfaq_controls.id = gwfaq_adms.title_id"
    item.page  params[:page], params[:limit]
    @faq_items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'gwfaq_controls.id')
  end

  def qa_index
    qa_admin_flags('_menu')
    @is_qa_admin = @is_admin
    if @is_sysadm
      qa_sysadm_index
    else
      qa_bbsadm_index
    end
  end

  def qa_sysadm_index
    item = Gwqa::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.page params[:page], params[:limit]
    @qa_items = item.find(:all, :order => 'sort_no, updated_at DESC')
  end

  def qa_bbsadm_index
    item = Gwqa::Control.new
    item.and "gwqa_controls.state", 'public'
    item.and "gwqa_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "gwqa_adms.user_code", Core.user.code
      end
      d.or do |d2|
        d2.and "gwqa_adms.user_id", 0
        d2.and "gwqa_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN gwqa_adms ON gwqa_controls.id = gwqa_adms.title_id"
    item.page params[:page], params[:limit]
    @qa_items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'gwqa_controls.id')
  end

end
