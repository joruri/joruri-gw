# -*- encoding: utf-8 -*-
################################################################################
#掲示板系板　ファイル添付選択処理
# gwboard_doc
# gwboard_file
# gwboard_db_file は、Gwboard::Model::DbnameAliasに記述があります
#
# 掲示板の処理を元に、
# 個別業務(gwsub)：広報依頼(sb05)：メルマガ：イベント情報
# の画像添付に流用
################################################################################

class Gwsub::Admin::AttachesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  #
  def pre_dispatch
    self.class.layout 'admin/gwsub_base'
    params[:parent_id] = params[:gwsub_id]
  end

  #現在の利用状態のメッセージを生成している
  #容量オーバーの判定を行っている
  #@disk_full:trueで容量オーバー
  def set_message
    @disk_full = false
    capacity = @title.upload_document_file_size_capacity.to_s + @title.upload_document_file_size_capacity_unit
    if @title.upload_document_file_size_capacity_unit == 'MB'
      used = @title.upload_document_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.megabyte.to_f
    else
      used = @title.upload_document_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.gigabytes.to_f
    end
    availability = (@title.upload_document_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @title.upload_document_file_size_capacity_unit

    @disk_full = true if capa_div < @title.upload_document_file_size_currently
    if @disk_full
      @capacity_message = '<span class="required">' + "利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。<br />"
      @capacity_message +='制限を超過しています。不要なファイルを削除するか、管理者にご連絡ください。</span>'
    else
      @capacity_message = "利用可能容量は#{capacity}です。現在約#{used}利用しています。利用率は約#{availability}%です。"
    end
    @max_file_message = "１ファイル#{@title.upload_document_file_size_max}MBまで登録可能です。"
  end

  #
  def index
    system = params[:system]
    case system
    when "sb01_training"
      item = Gwsub::Sb01TrainingFile.new
    else
      item = nil
    end

    if item.blank?
      @items = nil
    else
      item.and :parent_id, params[:parent_id]
      @items = item.find(:all)
    end
  end

  #
  def create
    @uploaded = params[:item]
    unless (@uploaded.nil? || @uploaded[:upload].blank?)
      @max_size = 3
      if @max_size.megabytes < @uploaded[:upload].size
        if @uploaded[:upload].size != 0
          mb = @uploaded[:upload].size.to_f / 1.megabyte.to_f
          mb = (mb * 100).to_i
          mb = sprintf('%g', mb.to_f / 100)
        end
        flash[:notice] = "ファイルサイズが制限を超えています。【最大#{@max_size}MBの設定です。】【#{mb}MBのファイルを登録しようとしています。】"
      else
        begin
          create_file(params[:system])
        rescue => ex
          if ex.message=~/File name too long/
            flash[:notice] = 'ファイル名が長すぎるため保存できませんでした。'
          else
            flash[:notice] = ex.message
          end
        end
      end
    end

    redirect_to "/_admin/gwsub/#{params[:parent_id]}/attaches?system=#{params[:system]}&menu_type=#{params[:menu_type]}"
  end

  def create_file(system)
    @uploaded = params[:item]
    unless @uploaded[:upload].blank?
      case system
      when "sb01_training"
        @item = Gwsub::Sb01TrainingFile.new
      else
        @item = nil
      end

      unless @item==nil
        @item.content_type = @uploaded[:upload].content_type
        @item.filename = @uploaded[:upload].original_filename
        @item.size = @uploaded[:upload].size
        @item.memo = @uploaded[:memo]
        @item.parent_id = params[:parent_id]
        @item.content_id = 1
        @item.db_file_id = 0  #0固定でDB格納との切り分けする予定
        @item._upload_file(@uploaded[:upload])
        @item.save
        @item.after_create
        
        if @item.content_type =~ /image/
          begin
            require 'RMagick'
            content = File.read(@item.f_name)
            image = Magick::Image.from_blob(content).shift
          if image.format =~ /(GIF|JPEG|PNG)/
            @item.width  = image.columns
            @item.height = image.rows
          end
          rescue LoadError
          rescue Magick::ImageMagickError
          rescue NoMethodError
          end

          @item.update_attribute(:width, image.columns)
          @item.update_attribute(:height, image.rows)
        end

      end
    end
  end

  # ファイル削除
  def destroy
    system = params[:system]
      case system
      when "sb01_training"
        item = Gwsub::Sb01TrainingFile.new
      else
        item = nil
      end
    unless item==nil
      @item = item.find(params[:id])
      @item.destroy
    end
    redirect_to gwsub_attaches_path(params[:parent_id])+ "?system=#{params[:system]}&menu_type=#{params[:menu_type]}"
  end


  #掲示板コントロールレコードに使用総サイズを保存する
  def update_total_file_size
    item = Gwsub::Sb01TrainingFile
    total = item.sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save
  end

  # 備考欄変更
  def update_file_memo
    file = Gwsub::Sb01TrainingFile
    @file = file.find_by_id(params[:id])
    @file.memo  = params[:file]['memo']
    @file.save

    parent_show_path  = "gwsub/sb01/sb01_training_plans/#{@file.parent_id}"
    redirect_to parent_show_path
  end

  private
  def invalidtoken

  end

end