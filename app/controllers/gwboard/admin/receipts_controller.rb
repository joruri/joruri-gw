class Gwboard::Admin::ReceiptsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  include DownloadHelper

  def pre_dispatch
    return http_error(404) if params[:system].blank?

    @title = gwboard_control.find(params[:title_id])
    return error_auth unless @title.is_readable?
  end

  def download_object
    item = @title.files.find_by(id: params[:id]) || @title.files.find_by(serial_no: params[:id], migrated: 1)

    if params[:system].to_s.in?(%w(gwbbs gwfaq)) && @title.upload_system == 2
      if item.is_image
        send_data(File.binread(item.f_name), filename: item.filename, type: item.content_type, disposition: 'inline')
      else
        send_data(File.binread(item.f_name), filename: item.filename, type: item.content_type)
      end
    else
      return http_error(404) unless item.db_file
      send_data(item.db_file.data, filename: item.filename, type: item.content_type)
    end
  end
end
