class Gwcircular::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
	layout 'admin/gwboard_base'

  def pre_dispatch
    @parent_id = params[:gwcircular_id]
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])
    @doc = @title.docs.find(@parent_id)
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
      redirect_to gwcircular_attachments_path(gwcircular_id: @parent_id, wiki: params[:wiki])
    else
      index
      render :index
    end
  end

  def destroy
    @item = @title.files.find(params[:id])
    @item.destroy

    redirect_to gwcircular_attachments_path(gwcircular_id: @parent_id, wiki: params[:wiki])
  end
end
