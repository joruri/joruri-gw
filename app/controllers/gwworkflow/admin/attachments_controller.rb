# -*- encoding: utf-8 -*-
class Gwworkflow::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @parent_id = params[:gwworkflow_id]
    self.class.layout 'admin/gwboard_base'
    params[:title_id] = 1
    @title = Gwworkflow::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    @doc_type = 0
    item = Gwworkflow::Doc.find_by_id(@parent_id)
    @doc_type = 0 #item.doc_type unless item.blank?
  end

  def index
    item = Gwworkflow::File.new
    item.and :title_id, 1
    item.and :parent_id, @parent_id
    item.order  'id'
    @items = item.find(:all);
  end

  def create
    @uploaded = params[:item]
    if @uploaded.blank?
      flash[:notice] = "ファイルが指定されていません。"
    else
      unless @uploaded[:upload].blank?
        if @uploaded[:upload].content_type.index("image").blank?
          @max_size = is_integer(@title.upload_document_file_size_max)
        else
          @max_size = is_integer(@title.upload_graphic_file_size_max)
        end
        @max_size = 5 if @max_size.blank?
        if @max_size.megabytes < @uploaded[:upload].size
          if @uploaded[:upload].size != 0
            mb = @uploaded[:upload].size.to_f / 1.megabyte.to_f
            mb = (mb * 100).to_i
            mb = sprintf('%g', mb.to_f / 100)
          end
          flash[:notice] = "ファイルサイズが制限を超えています。【最大#{@max_size}MBの設定です。】【#{mb}MBのファイルを登録しようとしています。】"
        else
          begin
            create_file
          rescue => ex
            if ex.message=~/File name too long/
              flash[:notice] = 'ファイル名が長すぎるため保存できませんでした。'
            else
              flash[:notice] = ex.message
            end
          end
        end
      end
    end

    redirect_to gwworkflow_attachments_path(@parent_id)
  end

  def create_file
    
    @uploaded = params[:item]
    unless @uploaded[:upload].blank?
      @item = Gwworkflow::File.new({
        :content_type => @uploaded[:upload].content_type,
        :filename => @uploaded[:upload].original_filename,
        :size => @uploaded[:upload].size,
        :memo => @uploaded[:memo],
        :title_id => params[:title_id],
        :parent_id => @parent_id,
        :content_id => @title.upload_system,
        :db_file_id => 0
      })
      @item._upload_file(@uploaded[:upload])
      @item.save
    end
  end

  def destroy
    @item = Gwworkflow::File.find_by_id(params[:id])
    @item.destroy
    redirect_to gwworkflow_attachments_path(@parent_id)
  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

  private
  def invalidtoken

  end
end