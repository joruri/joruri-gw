class Gwboard::Image  < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator

  attr_accessor :_upload
  attr_accessor :_update

  after_validation :set_fields
  after_save :file_save

  validates :memo, presence: true

  def share_states
    {'0' => '所属用背景画像', '1' => '所属用アイコン', '2' => '全庁用背景画像', '3' => '全庁用アイコン'}
  end
  def share_states_normal
    {'0' => '所属用背景画像', '1' => '所属用アイコン'}
  end
  def show_share_states
    if self.share.blank?
      ""
    elsif self.share == 0
      "所属用背景画像"
    elsif self.share == 1
      "所属用アイコン"
    elsif self.share == 2
      "全庁用背景画像"
    elsif self.share == 3
      "全庁用アイコン"
    else
      ""
    end
  end
  def range_of_use_name
    return [
      ['共通', 0] ,
      ['掲示板、質問管理', 10] ,
      ['書庫、電子図書', 20]]
  end

  def item_path
    return "/gwboard/images?st=#{self.share.to_s}"
  end
  def item_home_path
    return "/gwboard/files/"
  end
  def show_path
    ret = "#{self.item_home_path}#{self.id}"
    ret += "?st=1" if self.share == 1
    return ret
  end
  def edit_path
    ret = "#{self.item_home_path}#{self.id}/edit"
    ret += "?st=1" if self.share == 1
    return ret
  end
  def update_path
    ret = "#{self.item_home_path}#{self.id}/update"
    ret += "?st=1" if self.share == 1
    return ret
    return "#{Site.current_node.public_uri}#{self.id}/update?title_id=#{self.title_id}"
  end
    def delete_path
    ret = "#{self.item_home_path}#{self.id}/delete"
    ret += "?st=1" if self.share == 1
    return ret
  end

  def set_fields
#    return if self._update

    if self._upload.blank?
      errors.add :_upload, "ファイルを選択してください。"
      return false
    end

    if self._upload.content_type.index("image").blank?
      errors.add :_upload, "BMPは利用できません。GIF,JPEG,PNG形式が利用可能です。"
      return false
    end

    self.content_type = self._upload.content_type
    self.filename = self._upload.original_filename
    self.size = self._upload.size
    self.latest_updated_at = Time.now
    @tmp = self._upload.read

    if self.content_type =~ /^image/
      r_magick(@tmp)
    end
  end

  def f_path
    return "#{Rails.root}/public/_attaches/files/#{self.id}"
  end
  def f_name
    return "#{f_path}/#{self.filename}"
  end
  def file_path
    return "/_attaches/files/#{self.id}/#{self.filename}"
  end

  def name_rou
    case self.range_of_use
    when 0
      "共通"
    when 10
      "掲示板、質問管理"
    when 20
      "書庫、電子図書"
    else
      "共通"
    end
  end

  def file_save
    return true if @tmp.blank?
    FileUtils.mkdir_p(f_path) unless FileTest.exist?(f_path)
    File.open(f_name, "wb") { |f|
      f.write @tmp
    }
  end

  def r_magick(file)
    begin
      require 'RMagick'
      image = Magick::Image.from_blob(file).shift
      if image.format =~ /(GIF|JPEG|PNG)/
        self.width = image.columns
        self.height = image.rows
      end
    rescue
    end
  end

  def regulate_width(dst_h=nil)
    dst_h = 32.to_f if dst_h.blank?
    src_w  = self.width.to_f
    src_h  = self.height.to_f
    unless src_h == 0
      if dst_h < src_h
        src_r  = (dst_h / src_h)
        dst_w = src_w * src_r
        return "#{dst_w.ceil}x#{dst_h.ceil}"
      else
        return ""
      end
    else
      dst_w = 0
      dst_h = 0
      return ""
    end
  end

  def get_width(dst_h=nil)
    dst_h = 32.to_f if dst_h.blank?
    src_w  = self.width.to_f
    src_h  = self.height.to_f
    unless src_h == 0
      if dst_h < src_h
        src_r  = (dst_h / src_h)
        dst_w = src_w * src_r
        return "#{dst_w.ceil}"
      else
        return ""
      end
    else
      dst_w = 0
      dst_h = 0
      return ""
    end
  end

  def graphic_size
    str = "（#{self.width.to_s} x #{self.height.to_s}）"
    return str
  end

  def after_destroy
    dirlist = Dir::glob(f_path + "**/").sort {
      |a,b| b.split('/').size <=> a.split('/').size
    }
    begin

    dirlist.each {|d|
      Dir::foreach(d) {|f|
      File::delete(d+f) if ! (/\.+$/ =~ f)
      }
      Dir::rmdir(d)
    }
    rescue
    end
  end

private

  def set_creater_editor
    super(force_admin: true)
  end
end
