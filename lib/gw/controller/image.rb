# encoding: utf-8
module Gw::Controller::Image
  def _image_create(model_image, image_name, module_name, genre_name, params, options={})
    parent_id = params[:id]
    genre_name_prefix = nz(options[:genre_name_prefix])
    qs = Gw.join(@image_upload_qsa, '&amp;')
    qs = qs.blank? ? '' : "?#{qs}"
    redirect_uri = "/#{module_name}/#{("#{[genre_name_prefix,genre_name].delete_if{|x| x.nil?}.join('_')}").pluralize}/#{parent_id}/upload#{qs}"

    params[:item].delete :id
    params[:item][:parent_id] = parent_id
    idx = nz(model_image.maximum(:idx, :conditions => "parent_id = #{parent_id}"),0) + 1
    params[:item][:idx] = idx
    file = params[:item][:upload]

    unless file.blank?
      params[:item][:orig_filename] = file.original_filename
      content_type = file.content_type
      if /^image\// !~ content_type
        flash[:notice] = '画像以外はアップロードできません。'
        redirect_to redirect_uri
        return
      end

      params[:item][:content_type] = file.content_type
      path = %Q(/_common/modules/#{("#{[module_name,genre_name_prefix,genre_name].delete_if{|x| x.nil?}.join('_')}").pluralize}/#{parent_id}/#{idx}#{File.extname file.original_filename})
      params[:item][:path] = path
      filepath = RAILS_ROOT
      filepath += '/' unless filepath.ends_with?('/')
      filepath += "public#{path}"

      unless Gw.mkdir_for_file filepath
        flash[:notice] = 'ディレクトリの作成に失敗しました。'
        redirect_to redirect_uri
        return
      end
      File.open(filepath, 'wb') { |f| f.write file.read }
    else
      flash[:notice] = '添付画像ファイルを選択してください。'
      redirect_to redirect_uri
      return
    end
    params[:item].delete :upload
    item = model_image.new(params[:item])
    _create item, :success_redirect_uri=>redirect_uri, :notice => "#{image_name}の追加に成功しました。"
  end

  def _image_destroy(model_image, image_name, module_name, genre_name, params, options={})
    _img_id = params[:id]
    item = model_image.find(_img_id)

    genre_name_prefix = nz(options[:genre_name_prefix])
    qs = Gw.join(@image_upload_qsa, '&amp;')
    qs = qs.blank? ? '' : "?#{qs}"

    redirect_uri = "/#{module_name}/#{("#{[genre_name_prefix,genre_name].delete_if{|x| x.nil?}.join('_')}").pluralize}/#{item.parent_id}/upload#{qs}"
    _destroy item, :success_redirect_uri => redirect_uri, :notice => "#{image_name}の削除に成功しました。"
  end
  def _prop_image_destroy(model_image, image_name, module_name, genre_name, params, options={})
    _img_id = params[:id]
    item = model_image.find_by_id(_img_id)
    path = "#{RAILS_ROOT}/public#{item.path}"
    File.delete(path) if File.exist?(path)
    genre_name_prefix = nz(options[:genre_name_prefix])
    qs = Gw.join(@image_upload_qsa, '&amp;')
    qs = qs.blank? ? '' : "?#{qs}"
    redirect_uri = "/#{module_name}/#{("#{[genre_name_prefix,genre_name].delete_if{|x| x.nil?}.join('_')}").pluralize}/#{item.parent_id}/upload#{qs}"
    _destroy item, :success_redirect_uri => redirect_uri, :notice => "#{image_name}の削除に成功しました。"
  end
private
  def get_redirect_uri_for_image(model_image, image_name, module_name, genre_name, params, options={})

  end
end
