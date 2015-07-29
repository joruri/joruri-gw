# -*- encoding: utf-8 -*-
class Gwboard::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwboard::Model::DbnameAlias

  #layout "admin/base"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  #
  def initialize_scaffold
    self.class.layout 'admin/gwboard_base'

    return http_error(404) if params[:system].blank?

    item = gwboard_control
    @title = item.find_by_id(params[:title_id])
    return http_error(404) unless @title
    @disk_full = false
    @capacity_message = ''
    @max_file_message = ''
  end

  def set_graphic_warning_message
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
    disk_full = true if capa_div < @title.upload_graphic_file_size_currently
    if disk_full
      @capacity_message += '<div class="required">' + "画像ファイルの利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。<br />"
      @capacity_message +='制限を超過しています。不要なファイルを削除するか、管理者にご連絡ください。</div>'
    else
      @capacity_message += "画像ファイルの利用可能容量は#{capacity}です。現在約#{used}利用しています。<br />"
    end
    @disk_full ||= disk_full
    @max_file_message += "<br />画像ファイルは、１ファイル#{@title.upload_graphic_file_size_max}MBまで登録可能です。 "
  end

  def set_attaches_warning_message
    capacity = @title.upload_document_file_size_capacity.to_s + @title.upload_document_file_size_capacity_unit
    if @title.upload_document_file_size_capacity_unit == 'MB'
      used = @title.upload_document_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.megabyte.to_f
    else
      used = @title.upload_document_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@title.upload_document_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @title.upload_document_file_size_capacity_unit

    disk_full = true if capa_div < @title.upload_document_file_size_currently
    if disk_full
      @capacity_message += '<div class="required">' + "添付ファイルの利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。<br />"
      @capacity_message +='制限を超過しています。不要なファイルを削除するか、管理者にご連絡ください。</div>'
    else
      @capacity_message += "添付ファイルの利用可能容量は#{capacity}です。現在約#{used}利用しています。"
    end
    @disk_full ||= disk_full
    @max_file_message += "添付ファイルは、１ファイル#{@title.upload_document_file_size_max}MBまで登録可能です。"
  end

  #
  def index
    item = gwboard_file
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:parent_id]
    item.order  'id'
    @items = item.find(:all)
    set_graphic_warning_message
    set_attaches_warning_message
    gwboard_file_close
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

    redirect_to gwboard_attachments_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

  def create_file
    @uploaded = params[:item]
    unless @uploaded[:upload].blank?
      item = gwboard_file
      @item = item.new({
        :content_type => @uploaded[:upload].content_type,
        :filename => @uploaded[:upload].original_filename,
        :size => @uploaded[:upload].size,
        :memo => @uploaded[:memo],
        :title_id => params[:title_id],
        :parent_id => params[:parent_id],
        :content_id => @title.upload_system,
        :db_file_id => 0
      })
      @item._upload_file(@uploaded[:upload])
      @item.save
      update_total_file_size
      gwboard_file_close
      gwboard_db_file_close
    end
  end

  def destroy
    item = gwboard_file
    @item = item.find_by_id(params[:id])
    @item.destroy
    update_total_file_size
    gwboard_file_close
    redirect_to gwboard_attachments_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

  def update_total_file_size
    item = gwboard_file
    total = item.sum(:size,:conditions => 'unid = 1')
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f

    total = item.sum(:size,:conditions => 'unid = 2')
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f

    @title.save
  end

  def update_file_memo
    file = gwboard_file
    @file = file.find_by_id(params[:id])
    @file.memo  = params[:file]['memo']
    @file.save

    ret = ''
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    ret += "&grp=#{params[:grp]}" unless params[:grp].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{params[:kwd]}" unless params[:kwd].blank?

    if params[:system].to_s == 'doclibrary'
      if @title.form_name == 'form002'
        parent  = Doclibrary::Doc.find(:first,:conditions=>"id=#{params[:parent_id]}")
        parent_show_path  = "/doclibrary/docs/#{parent.id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      else
        parent_show_path  = "/doclibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      end
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'digitallibrary'
      parent_show_path  = "/digitallibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'gwbbs'
      parent_show_path  = "/gwbbs/docs/#{@file.parent_id}?title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end
    gwboard_file_close
    redirect_to gwboard_attachments_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

  private
  def invalidtoken

  end
end