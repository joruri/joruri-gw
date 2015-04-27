class Gwmonitor::Admin::Menus::FileExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @title = Gwmonitor::Control.find(params[:title_id])
    return error_auth unless @title.is_admin?
  end

  def index
  end

  def export_file
    zipdata = @title.compress_files(encoding: params[:item][:nkf] == 'sjis' ? 'Shift_JIS' : 'UTF-8')

    if zipdata.present?
      file_name = @title.title[0,100]
      file_name = file_name + "_#{Time.now.strftime("%Y%m%d%H%M%S")}.zip"
      send_data zipdata, filename: file_name
    else
      flash[:notice] = '出力対象の添付ファイルがありません。'
      redirect_to "/gwmonitor/#{@title.id}/file_exports"
    end
  end
end
