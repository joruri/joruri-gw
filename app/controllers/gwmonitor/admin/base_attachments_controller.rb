class Gwmonitor::Admin::BaseAttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/gwboard_base'

  def pre_dispatch
    @parent_id = params[:gwmonitor_id]
    @title = Gwmonitor::Control.find(@parent_id)
  end

  def index
    @items = @title.base_files.order(:id)
  end

  def create
    @item = @title.base_files.build(
      file: params[:item].try('[]', :upload),
      memo: params[:item].try('[]', :memo),
      parent_id: @title.id,
      content_id: @title.upload_system,
      db_file_id: 0
    )

    if @item.save
      redirect_to gwmonitor_base_attachments_path(monitor_id: @title.id, title_id: @title.id, wiki: params[:wiki])
    else
      index
      render :index
    end
  end

  def destroy
    @item = @title.base_files.find(params[:id])
    @item.destroy

    redirect_to gwmonitor_base_attachments_path(monitor_id: @title.id, title_id: @title.id, wiki: params[:wiki])
  end
end
