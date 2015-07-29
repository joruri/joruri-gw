# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def pre_dispatch
    Page.title = "照会・回答システム"
    @title_id = params[:title_id]
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find_by_id(@title_id)
    return http_error(404) unless @title
  end

  def is_admin
    system_admin_flags
    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    return ret
  end

  def index
    return authentication_error(403) unless is_admin
    params[:nkf] = 'sjis'
  end

  def export_csv
    return authentication_error(403) unless is_admin
    filename = "gwmonitor#{Time.now.strftime('%Y%m%d%H%M%S')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    item = Gwmonitor::Doc.new
    item.and :title_id , @title.id
    item.and 'sql', "state != 'preparation'"
    item.order 'section_sort, l2_section_code, section_code'
    items = item.find(:all,:select=>"title_id, id, state, section_code, section_name, editor_id, editor, body, editdate")

    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  []
    csv_header << "アンケートid"
    csv_header << "アンケート名"
    csv_header << "状態"
    csv_header << "所属コード"
    csv_header << "所属名"
    csv_header << "回答者名"
    csv_header << "返信欄"
    csv_header << "回答日時"

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    send_data(NKF::nkf(nkf_options,csv_string), :type => 'text/csv', :filename => "#{filename}.csv")
  end

  def make_csv(b)
    data = []
    data << b.title_id.to_s
    data << @title.title.to_s
    data << b.status_name_csv.to_s
    data << b.section_code.to_s
    data << b.section_name.to_s
    data << b.editor.to_s
    data << b.body.to_s
    data << b.editdate.to_s
    return data
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
