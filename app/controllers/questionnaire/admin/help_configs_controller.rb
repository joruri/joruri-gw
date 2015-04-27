class Questionnaire::Admin::HelpConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/admin"

  def pre_dispatch
    system_admin_flags
    return error_auth unless @is_sysadm

    @css = ["/_common/themes/gw/css/circular.css"]
    Page.title = 'アンケート集計システムヘルプ設定'
  end

  def index
    @item = Questionnaire::Property::HelpLink.first_or_new
  end

  def edit
    @item = Questionnaire::Property::HelpLink.first_or_new
    return http_error(404) unless @item
  end

  def update
    @item = Questionnaire::Property::HelpLink.first_or_new
    return http_error(404) unless @item

    @item.options_value = params[:item].sort.map(&:last)
    @item.save
    redirect_to url_for(:action => :edit)
  end
end
