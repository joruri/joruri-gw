class Gwcircular::Admin::Menus::FileExportsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])
    @item = @title.docs.find(params[:id])
    return error_auth if !@title.is_admin? && @item.target_user_code != Core.user.code

    @parent = @title.docs.find(@item.parent_id)
    return http_error(404) unless @parent.doc_type == 0

    Page.title = @title.title
  end

  def index
  end

  def export_file
    zipdata = @parent.compress_files(encoding: params[:item][:nkf] == 'sjis' ? 'Shift_JIS' : 'UTF-8')

    if zipdata.present?
      file_name = "#{@title.title}_#{@item.title}"[0,100]
      file_name = file_name + "_#{Time.now.strftime("%Y%m%d%H%M%S")}.zip"
      send_data zipdata, filename: file_name
    else
      flash[:notice] = '出力対象の添付ファイルがありません。'
      redirect_to "/gwcircular/#{@item.id}/file_exports"
    end
  end
end
