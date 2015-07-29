# -*- encoding: utf-8 -*-
################################################################################
#
################################################################################
class Questionnaire::Admin::Menus::AnswersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム　回答確認'
    Page.title = @system_title
    params[:limit] = 50

    @title = Questionnaire::Base.find_by_id(params[:parent_id])
    return http_error(404) unless @title
    return http_error(404) if @title.form_body.blank?
    @field_lists = JsonParser.new.parse(@title.form_body_json)
    return http_error(404) if @field_lists.size == 0
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Site.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Site.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return authentication_error(403) unless is_creator

    item = Enquete::Answer.new
    item.and :title_id, @title.id
    item.and :state, '!=', 'preparation'
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'state, id')
    _index @items
  end

  def show
    return authentication_error(403) unless is_creator

    @item = Enquete::Answer.find_by_id(params[:id])
    return http_error(404) unless @item

    _show @item
  end

end
