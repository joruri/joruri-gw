class Gw::Admin::Files::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'admin/gwboard_base'

  def pre_dispatch
    return http_error(404) if params[:system].blank?


  end

  def index

    case params[:system]
    when 'memo'
      @items = Gw::MemoFile.where(tmp_id: params[:parent_id])
    else
      @item = nil
    end
  end

  def create
    case params[:system]
    when 'memo'
      @item = Gw::MemoFile.new({
        tmp_id: params[:parent_id],
        file: params[:item][:upload]
        })
    else
      @item = nil
    end

    if @item.save
      redirect_to gw_attachments_path(parent_id: params[:parent_id], system: params[:system])
    else
      index
      render :index
    end
  end

  def destroy
    case params[:system]
    when 'memo'
      @item = Gw::MemoFile.where(tmp_id: params[:parent_id], id: params[:id]).first
    else
      @item = nil
    end
    return error_auth if @item.blank?
    @item.destroy

    redirect_to gw_attachments_path(parent_id: params[:parent_id], system: params[:system])
  end

end
