class Gw::Admin::Files::AjaxuploadsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout false

  def pre_dispatch
    return http_error(404) if params[:system].blank?
    @parent_id = params[:parent_id]
  end

  def create
    @files = []
    if params[:files]
      params[:files].each do |file|
        case params[:system]
        when 'memo'
          item = Gw::MemoFile.new({
            tmp_id: params[:parent_id],
            file: file
            })
        when 'schedule'
          item = Gw::ScheduleFile.new({
            tmp_id: params[:parent_id],
            file: file
            })
        else
          next
        end
        if item.save
          @files << item
        end
      end
    end

    respond_to do |format|
      format.html {}
      format.json {
        render :json => @files.to_json
      }
    end
  end

end
