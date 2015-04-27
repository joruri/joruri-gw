################################################################################
#
################################################################################
class Questionnaire::Admin::Menus::AnswersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システム　回答確認'
    params[:limit] = 50

    @title = Questionnaire::Base.where(:id => params[:parent_id]).first
    return http_error(404) unless @title
    return http_error(404) if @title.form_body.blank?
    @field_lists = JSON.parse(@title.form_body)
    return http_error(404) if @field_lists.size == 0
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Core.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Core.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Core.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Core.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return error_auth unless is_creator

    item = Enquete::Answer.new
    item.and :title_id, @title.id
    item.and :state, '!=', 'preparation'
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'state, id')
    _index @items
  end

  def show
    return error_auth unless is_creator

    @item = Enquete::Answer.where(:id => params[:id]).first
    return http_error(404) unless @item

    _show @item
  end

end
