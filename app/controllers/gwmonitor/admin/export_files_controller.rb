# -*- encoding: utf-8 -*-
class Gwmonitor::Admin::ExportFilesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def pre_dispatch
    @title_id = params[:gwmonitor_id]
    @title = Gwmonitor::Control.find_by_id(@title_id)
    return http_error(404) unless @title
  end

  def index
    f_name = "gwmonitor#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
    f_name = params[:f_name] unless params[:f_name].blank?
    target_zip_file ="#{Rails.root}/tmp/gwmonitor/#{f_name}"
    send_file target_zip_file if FileTest.exist?(target_zip_file)

    unless FileTest.exist?(target_zip_file)
      flash[:notice] = '出力対象の添付ファイルがありません。'
      redirect_to "/gwmonitor/#{@title.id}/file_exports"
    end
  end

  private
  def invalidtoken

  end
end