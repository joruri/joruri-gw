class Gwboard::Admin::AjaxuploadsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout false

  def pre_dispatch
    return http_error(404) if params[:system].blank?
    case params[:system]
    when 'gwmonitor'
      @parent_id = params[:gwmonitor_id]
      @title = Gwmonitor::Control.find(params[:title_id])
    when 'gwcircular'
      @title = Gwcircular::Control.find(params[:title_id])
      @doc = @title.docs.find(@parent_id)
      @parent_id = params[:gwcircular_id]
    when 'gwworkflow'
      @parent_id = params[:gwworkflow_id]
      @title = Gwworkflow::Control.find(params[:title_id])
    else
      @title = Gwboard.control_model(params[:system]).find(params[:title_id])
      @parent_id = params[:parent_id]
    end
  end

  def create
    if params[:files]
      params[:files].each do |file|
        @item = @title.files.build(
          file: file,
          parent_id: @parent_id,
          content_id: @title.upload_system,
          db_file_id: 0
        )
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
