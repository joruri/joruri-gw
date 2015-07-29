# -*- encoding: utf-8 -*-
class Gwboard::Admin::ImagesController < ApplicationController

  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwboard::Model::DbnameAlias

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def set_message
    capacity = @title.upload_graphic_file_size_capacity.to_s + @title.upload_graphic_file_size_capacity_unit
    if @title.upload_graphic_file_size_capacity_unit == 'MB'
      used = @title.upload_graphic_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @title.upload_graphic_file_size_capacity.megabyte.to_f
    else
      used = @title.upload_graphic_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @title.upload_graphic_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@title.upload_graphic_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @title.upload_graphic_file_size_capacity_unit
    @disk_full = true if capa_div < @title.upload_graphic_file_size_currently
    if @disk_full
      @capacity_message = '<span class="required">' + "利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。<br />"
      @capacity_message +='制限を超過しています。不要なファイルを削除するか、管理者にご連絡ください。</span>'
    else
      @capacity_message = "利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。"
    end
    @max_file_message = "１ファイル#{@title.upload_graphic_file_size_max}MBまで登録可能です。"
  end


  def initialize_scaffold
    self.class.layout 'admin/base'

    return http_error(404) if params[:system].blank?

    item = gwboard_control
    @title = item.find_by_id(params[:title_id])
    return http_error(404) unless @title

    @img_path = "public/_common/modules/#{params[:system]}/"

  end

  def index

    item = gwboard_doc
    item = item.new
    @doc = item.find(params[:parent_id])
    gwboard_doc_close
    return http_error(404) if @doc.blank?

    item = gwboard_image
    item = item.new
    item.and :parent_id, @doc.id
    @items = item.find(:all,:order => 'id DESC')

    set_message
    gwboard_image_close
  end

  def new
    item = gwboard_image
    @item = item.new({
    })
  end

  def update_total_file_size
    item = gwboard_image
    total = item.sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    @title.save
  end

  def create

    item = gwboard_doc
    item = item.new
    item.and :id, params[:parent_id]
    doc = item.find(:first)
    return http_error(404) if doc.blank?

    flg_upload = true
    @uploaded = params[:item]
    #
    if @uploaded.blank?
        flg_upload = false
        flash[:notice] = 'ファイルを指定してください。'
    end
    if @uploaded[:uploaded_data].content_type.to_s.index("bmp")
        flg_upload = false
        flash[:notice] = '記事の画像はBMP形式以外のフォーマットをご利用ください。'
    end unless @uploaded.blank?
    #
    unless @uploaded[:uploaded_data].content_type.to_s.index("image")
      flg_upload = false
      flash[:notice] = '記事に掲載する画像以外のファイルは添付機能をご利用ください。'
    end unless @uploaded.blank?
    #
    @max_size = is_integer(@title.upload_graphic_file_size_max)
    @max_size = 3 unless @max_size
    if @max_size.megabytes < @uploaded[:uploaded_data].size
      mb = @uploaded[:uploaded_data].size.to_f / 1.megabyte.to_f
      mb = (mb * 100).to_i
      mb = sprintf('%g', mb.to_f / 100)
      flg_upload = false
      flash[:notice] = "ファイルサイズが制限を超えています。【最大#{@max_size}MBの設定です。】【#{mb}MBのファイルを登録しようとしています。】"
    end unless @uploaded.blank?

    begin
        create_file(doc)
        update_total_file_size
    rescue => ex
        if ex.message=~/File name too long/
          flash[:notice] = 'ファイル名が長すぎるため保存できませんでした。'
        else
          flash[:notice] = ex.message
        end
    end if flg_upload

    redirect_to gwboard_images_path(doc.id) + "?system=#{params[:system]}&title_id=#{doc.title_id}&form_id=#{params[:form_id]}"
  end

  def create_file(doc)
    item = gwboard_image
    item.has_attachment(
      :content_type => :image,
      :storage => :file_system,
      :max_size => 10.megabytes,
      :size => 1.byte..100.megabytes,
      :path_prefix => "#{@img_path}#{sprintf("%06d", doc.title_id)}/#{doc.name}/"
    )
    item = item.new(params[:item])
    if item.save

      item.parent_id = doc.id
      item.latest_updated_at = Time.now
      item.parent_name = doc.name
      item.title_id = doc.title_id
      item.save
    end
  end

  def destroy
    item = gwboard_doc
    item = item.new
    item.and :id, params[:parent_id]
    @doc = item.find(:first)
    return http_error(404) if @doc.blank?

    item = gwboard_image
    item.has_attachment(:content_type => :image,
    :storage => :file_system,
    :path_prefix => "#{@img_path}#{sprintf("%06d", @doc.title_id)}/#{@doc.name}/"
    )

    @item = item.find(params[:id])
    begin
      @item.image_delete(@img_path)
    rescue
    end
    @item.destroy

    update_total_file_size
    redirect_to gwboard_images_path(@doc.id) + "?system=#{params[:system]}&title_id=#{@doc.title_id}&form_id=#{params[:form_id]}"
  end

private
  def invalidtoken

  end

end
