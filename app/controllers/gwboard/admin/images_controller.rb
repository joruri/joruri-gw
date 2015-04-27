class Gwboard::Admin::ImagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout 'admin/base'

  def pre_dispatch
    return http_error(404) if params[:system].blank?

    @title = gwboard_control.find(params[:title_id])
  end

  def index
    @doc = @title.docs.find(params[:parent_id])
    @items = @doc.images.order(id: :desc)
  end

  def create
    @doc = @title.docs.find(params[:parent_id])
    @item = @doc.images.build(
      file: params[:item].try('[]', :upload),
      memo: params[:item].try('[]', :memo),
      parent_id: params[:parent_id]
    )

    if @item.save
      redirect_to gwboard_images_path(parent_id: params[:parent_id], system: params[:system], title_id: params[:title_id], form_id: params[:form_id], wiki: params[:wiki])
    else
      index
      render :index
    end
  end

  def destroy
    @doc = gwboard_doc.find(params[:parent_id])
    @item = @doc.images.find(params[:id])
    @item.destroy

    redirect_to gwboard_images_path(parent_id: @doc.id, system: params[:system], title_id: @doc.title_id, form_id: params[:form_id], wiki: params[:wiki])
  end
end
