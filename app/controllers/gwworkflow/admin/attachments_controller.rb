class Gwworkflow::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/gwboard_base'

  def pre_dispatch
    @parent_id = params[:gwworkflow_id]
    params[:title_id] = 1
    @title = Gwworkflow::Control.find(params[:title_id])
  end

  def index
    @items = @title.files.where(parent_id: @parent_id).order(:id)
  end

  def create
    @item = @title.files.build(
      file: params[:item].try('[]', :upload),
      memo: params[:item].try('[]', :memo),
      parent_id: @parent_id,
      content_id: @title.upload_system,
      db_file_id: 0
    )

    if @item.save
      redirect_to gwworkflow_attachments_path(@parent_id)
    else
      index
      render :index
    end
  end

  def destroy
    @item = @title.files.find(params[:id])
    @item.destroy

    redirect_to gwworkflow_attachments_path(@parent_id)
  end
end
