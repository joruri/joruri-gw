# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::HelpConfigsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname

  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システムヘルプ設定"
    @system_title = "#{disp_system_name}ヘルプリンク設定"
    @css = ["/_common/themes/gw/css/monitor.css"]
  end

  def index
    system_admin_flags
    return authentication_error(403) unless @is_sysadm
    @array_help = Array.new(2, ['', ''])

    @item = Gw::UserProperty.gwmonitor_help_links.find(:first)
    if @item && (! @item.options.nil?)
      @array_help = JsonParser.new.parse(@item.options)
    else
      @item = Gw::UserProperty.create({
        :class_id   => 3,
        :name       => 'gwmonitor',
        :type_name  => 'help_link',
        :options    => Array.new(2, [""]).to_json
      })
    end
  end

  #
  def update
    @item = Gw::UserProperty.find_by_id(params[:id])
    return http_error(404) unless @item
    
    @item.options = [[params[:help_0].to_s], [params[:help_1].to_s]].to_json
    @item.save
    redirect_to '/gwmonitor/settings'
  end

end
