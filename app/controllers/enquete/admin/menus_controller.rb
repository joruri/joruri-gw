################################################################################
#基本情報登録
################################################################################
class Enquete::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システム'
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
    item = Questionnaire::Base.new
    item.join "left join enquete_answers on questionnaire_bases.id = enquete_answers.title_id AND enquete_answers.user_code = '#{Core.user.code}'"
    @items = item.find(:all, :select =>  "distinct questionnaire_bases.*, enquete_answers.id AS ans_id",
    :conditions=>["questionnaire_bases.include_index = ? AND enquete_answers.id IS NULL AND questionnaire_bases.state = ?", true,'public' ] , :order=>:expiry_date)
    _index @items
  end

  #回答済一覧
  #['記名', true], ['無記名', false]
  def answered_index
    check_user_record

    item = Enquete::Answer.new
#    item.and :enquete_division, true
    item.and :user_code, Core.user.code
#    item.and :expiry_date, '>=', Time.now
    item.order 'expiry_date DESC'
    item.page(params[:page], params[:limit])
    @items = item.find(:all)
    _index @items
  end

  def check_user_record
    user = Enquete::BaseUser.where(:base_user_code => Core.user.code).first
    if user.blank?
      user = Enquete::BaseUser.new({
        :base_user_code => Core.user.code ,
        :base_user_name => Core.user.name
      })
      user.save
    end
  end

end
