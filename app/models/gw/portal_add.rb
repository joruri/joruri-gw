# encoding: utf-8
class Gw::PortalAdd  < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

  def set_creator
    self.created_at     = Time.now
    self.created_user   = Site.user.name
    self.created_group  = Site.user_group.id
  end

  def set_updator
    self.updated_at     = Time.now
    self.updated_user   = Site.user.name
    self.updated_group  = Site.user_group.id
  end

  def self.is_admin?( uid = Site.user.id )
    is_admin = System::Model::Role.get(1, uid ,'_admin', 'admin')
    return is_admin
  end

  def self.published_select
    published = [['公開','opened'],['非公開','closed']]
    return published
  end

  def self.published_show(published)
    publishes = [['closed','非公開'],['opened','公開']]
    show_str = publishes.assoc(published)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.place_select(all=nil)
    places = [['ポータル左上',1],['ポータル下部',2]]
    places = [['すべて',0]] + places if all=='all'
    return places
  end

  def self.places_show(place)
    places = self.place_select
    places.each {|a| return a[0] if a[1] ==  place }
    return nil
  end

  def self.params_set(params)
    ret = ""
    'page'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def adds_data_save(params, mode, options={})

    extname_judges = [".jpeg", ".jpg", ".png", ".gif"]

    par_item = params[:item].dup

    file = par_item[:upload]
    par_item.delete :upload
    par_item.delete :local_file_path
    update_image = Hash::new

    if par_item[:title].blank?
      self.errors.add :title, 'を入力してください。'
    end
    if par_item[:sort_no].blank?
      self.errors.add :sort_no, 'を入力してください。'
    else
      unless par_item[:sort_no].to_s =~ /^[0-9]+$/
        self.errors.add :sort_no, 'は、数値で入力してください。'
      end
    end
    if par_item[:publish_start_at].blank?
      self.errors.add :publish_start_at, 'を入力してください。'
    else
      unless(par_item[:publish_end_at].blank?)
        if Gw.date_str(par_item[:publish_end_at]) <= Gw.date_str(par_item[:publish_start_at])
          self.errors.add :publish_end_at, 'は、掲載開始日より後の日付を入力してください。'
        end
      end
    end
    if par_item[:publish_end_at].blank?
      self.errors.add :publish_end_at, 'を入力してください。'
    end

    unless file.blank?
      upload_file = file.read
      content_type = file.content_type
      if /^image\// !~ content_type
        self.errors.add :upload, 'は、画像以外はアップロードできません。'
      end
      original_file_name = file.original_filename
      extname = File.extname(original_file_name)
      if extname_judges.index(extname.downcase).blank?
        self.errors.add :upload, 'は、jpeg, jpg, png, gifの拡張子以外の画像はアップロードできません。'
      end
      image_size = r_magick(upload_file)
      unless image_size[0] == "failed"
        if (image_size[1] > 170 or image_size[2] > 50)
          self.errors.add :upload, 'のサイズは、横170ピクセル×縦50ピクセル以内にしてください。'
        end
      end
    else
      if mode == :create
        self.errors.add :upload, 'に、添付画像ファイルを選択してください。'
      elsif mode == :update
        update_image[:file_path] = self.file_path
        update_image[:file_directory] = self.file_directory
        update_image[:file_name] = self.file_name
        update_image[:original_file_name] = self.original_file_name
        update_image[:content_type] = self.content_type
        image_size = ['success',self.width, self.height]
      end
    end

    self.attributes = par_item
    if mode == :update
      save_flg = self.errors.size == 0 && self.editable? && self.save()
    elsif mode == :create
      save_flg = self.errors.size == 0 && self.creatable? && self.save()
    end

    if save_flg && !file.blank?
      image = Hash::new
      image[:content_type] = file.content_type

      image[:original_file_name] = original_file_name
      directory = "/_common/themes/gw/files/portal/adds/#{self.id}/"

      filename = "#{self.id}#{extname}"
      image[:file_name] = filename
      image[:file_directory] = directory
      image[:width] = image_size[1]
      image[:height] = image_size[2]
      file_path = %Q(#{directory}#{filename})
      image[:file_path] = file_path
      upload_path = RAILS_ROOT
      upload_path += '/' unless upload_path.ends_with?('/')
      upload_path += "public#{file_path}"
      unless Gw.mkdir_for_file upload_path

        self.errors.add :upload, 'ディレクトリが作成できません。'
      end

      if self.errors.size == 0
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f| f.write(upload_file) }
        self.attributes = image
        self.save()
        return true
      else

        if self.deletable? && self.destroy
          return false
        else

          return false
        end
      end
    elsif save_flg && file.blank? && mode == :update

      self.attributes = update_image
      self.save()
    else
      return false
    end
  end

  def r_magick(file)
    begin
      require 'RMagick'
      image = Magick::Image.from_blob(file).shift
      if image.format =~ /(GIF|JPEG|PNG)/
        result = "success"
        width = image.columns
        height = image.rows
      else
        result = "failed"
        width = 0
        height = 0
      end
    rescue
        result = "failed"
        width = 0
        height = 0
    end
      return [result,width,height]
  end

  def self.get_max_sort_no

    cond  = "state!='deleted'"
    order = "sort_no DESC"
    max_sort = self.find(:first , :order=>order , :conditions=>cond)
    if max_sort.blank?
      max_sort_no = 0
    else
      max_sort_no = max_sort.sort_no
    end
    return max_sort_no.to_i + 10
  end
end

