class Gwboard::Admin::AjaxuploadsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout false

  def pre_dispatch
    return http_error(404) if params[:system].blank?
    @parent_id = params[:parent_id]
    case params[:system]
    when 'gwmonitor_base'
      @title = Gwmonitor::Control.find(@parent_id)
    when 'gwmonitor'
      @title = Gwmonitor::Control.find(params[:title_id])
    when 'gwcircular'
      @title = Gwcircular::Control.find(params[:title_id])
      @doc = @title.docs.find(@parent_id)
    when 'gwworkflow'
      @title = Gwworkflow::Control.find(params[:title_id])
    else
      @title = Gwboard.control_model(params[:system]).find(params[:title_id])
    end
  end

  def create
    if params[:files]
      params[:files].each do |file|
        if params[:system] == 'gwmonitor_base'
          @item = @title.base_files.build(
            file: file,
            parent_id: @parent_id,
            content_id: @title.upload_system,
            db_file_id: 0
          )
        else
          @item = @title.files.build(
            file: file,
            parent_id: @parent_id,
            content_id: @title.upload_system,
            db_file_id: 0
          )
        end

      end
    end

    if @item.save
      respond_to do |format|
        format.html {}
        format.json {
          render :json => @item.to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

end
