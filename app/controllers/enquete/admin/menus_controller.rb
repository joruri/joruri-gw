# -*- encoding: utf-8 -*-
################################################################################
#基本情報登録
################################################################################
class Enquete::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム'
    Page.title = @system_title
  end

  def index
    system_admin_flags
    if params[:cond].blank?
      unanswered_index
    else
      answered_index
    end
  end

  #未回答一覧
  def unanswered_index
    check_user_record

    sql  = "SELECT `enquete_view_questions`.*"
    sql +=" FROM `enquete_view_questions` LEFT JOIN `enquete_answers`"
    sql +=" ON  (`enquete_view_questions`.`id` = `enquete_answers`.`title_id`)"
    sql +=" AND (`enquete_view_questions`.`base_user_code` = `enquete_answers`.`user_code`)"
    sql +=" WHERE (`enquete_answers`.`state` IS NULL)"
    sql +=" AND (`enquete_view_questions`.`include_index` = #{true})"
    sql +=" AND (`enquete_view_questions`.`base_user_code` = '#{Site.user.code}')"
    sql +=" ORDER BY `enquete_view_questions`.`expiry_date`"
    @items = Enquete::ViewQuestion.find_by_sql(sql)
    _index @items
  end

  #回答済一覧
  #['記名', true], ['無記名', false]
  def answered_index
    check_user_record

    item = Enquete::Answer.new
#    item.and :enquete_division, true
    item.and :user_code, Site.user.code
#    item.and :expiry_date, '>=', Time.now
    item.order 'expiry_date DESC'
    item.page(params[:page], params[:limit])
    @items = item.find(:all)
    _index @items
  end

  def check_user_record
    user = Enquete::BaseUser.find_by_base_user_code(Site.user.code)
    if user.blank?
      user = Enquete::BaseUser.new({
        :base_user_code => Site.user.code ,
        :base_user_name => Site.user.name
      })
      user.save
    end
  end

end
