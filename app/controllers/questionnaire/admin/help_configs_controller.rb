# -*- encoding: utf-8 -*-
###############################################################################
#対象レコードが存在する事が前提です。
#
###############################################################################

class Questionnaire::Admin::HelpConfigsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/admin"

  def initialize_scaffold
    @system_title = 'アンケート集計システムヘルプ設定'
    Page.title = @system_title
    @css = ["/_common/themes/gw/css/circular.css"]
  end

  #
  #-主なアクションの記述 START index,show,new,edit,update, destroy---------------
  def index
    system_admin_flags
    return authentication_error(403) unless @is_sysadm

    item = Gw::UserProperty.new
    item.and :class_id, 3
    item.and :name, 'enquete'
    item.and :type_name, 'help_link'
    @item = item.find(:first)
    return http_error(404) unless @item
    @array_help = Array.new(10, "")
    @array_help = JsonParser.new.parse(@item.options) unless @item.blank?
  end

  #
  def update
    @item = Gw::UserProperty.find_by_id(params[:id])
    return http_error(404) unless @item
    help_0 = "[" + '"' + params[:help_0].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_1 = "[" + '"' + params[:help_1].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_2 = "[" + '"' + params[:help_2].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_3 = "[" + '"' + params[:help_3].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_4 = "[" + '"' + params[:help_4].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_5 = "[" + '"' + params[:help_5].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    help_6 = "[" + '"' + params[:help_6].to_s.gsub(/\"/,"\\\"") + '"' + "]"
    @item.options = "[" + "#{help_0}, #{help_1}, #{help_2}, #{help_3}, #{help_4}, #{help_5}, #{help_6}" + "]"
    @item.save
    redirect_to '/questionnaire/help_configs'
  end

  #-主なアクションの記述 END index ---------------------------------------------------

end
