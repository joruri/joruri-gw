# -*- encoding: utf-8 -*-
module Cms::Model::Base::File
  def self.included(mod)
    mod.before_validation_on_create :validate_upload
    mod.after_validation :validate_name
    mod.before_save    :validate_file
    mod.after_save     :save_files
    mod.before_destroy :remove_files
  end

  @@file_max_size = '20MB'

  def states
    {'draft' => '下書き保存', 'recognize' => '承認待ち'}
  end

  def readable
  end

  def editable
  end

  def deletable
  end

  def public
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def public?
  end

  def file
    return @@file if defined?(@@file)
  end

  def file=(file)
    @@file = file
  end

  def image?
    image_is == 1 ? true : nil
  end

  def escaped_name
    CGI::escape(name)
  end

  def united_name
    title + '(' + eng_unit + ')'
  end

  def alt
    title
  end

  def skip_upload(flag = true)
    @skip_upload = flag
  end

  def validate_upload
    return true if @skip_upload == true
    self.class.validates_presence_of :file
  end

  def validate_name

  end

  def duplicated?
    return false
  end

  def validate_file
    return false if errors.size > 0

    return true if file.to_s == ''

    max_size = eval("#{@@file_max_size.gsub(/MB/i, '*(1024**2)')}")
    if file.size > max_size
      errors.add_to_base "ファイルサイズが #{@@file_max_size} を超えています (#{file.original_filename})"
      return false
    end

    self.name         = file.original_filename if name.to_s == ''
    self.title        = self.name if title.to_s == ''
    self.mime_type    = file.content_type
    self.size         = file.size

    unless self.name =~ /^[0-9a-zA-Z\-\_\.]+$/
      errors.add :name, "半角英数字を入力してください (#{self.name})"
      return false
    end

    unless File::extname(name).downcase[1..5]
      if ext = File::extname(file.original_filename).downcase[1..5]
        self.name += '.' + ext
      else
        errors.add(:name, '拡張子がありません')
      end
    end

    if duplicated?
      errors.add_to_base "同名ファイルが存在しています (#{file.original_filename})"
      return false
    end

    @file_data = file.read
    self.image_is     = 2
    self.image_width  = nil
    self.image_height = nil

    begin
      require 'RMagick'
      image = Magick::Image.from_blob(@file_data).shift
      if image.format =~ /(GIF|JPEG|PNG)/
        self.image_is = 1
        self.image_width  = image.columns
        self.image_height = image.rows
      end
    rescue LoadError
    rescue Magick::ImageMagickError
    rescue NoMethodError
    end
  end

  def save_files
    if file.to_s != ''
      remove_files
      Util::File.put(upload_path, :data => @file_data, :mkdir => true)
      file = ''
    end
  end

  def remove_files
    dir = File::dirname(upload_path)
    return true unless FileTest.exist?(dir)
    FileUtils.remove_entry_secure(dir)
  end

  def css_class
    list = {
      'bmp'  => 'bmp',
      'doc'  => 'doc',
      'gif'  => 'gif',
      'jpg'  => 'jpg',
      'jpeg' => 'jpg',
      'jtd'  => 'jtd',
      'pdf'  => 'pdf',
      'xls'  => 'xls',
      'xlsx' => 'xls',
    }

    if ext = File::extname(name).downcase[1..5]
      ext = ext.gsub(/[^0-9a-z]/, '')
      return 'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    end
    return 'iconFile'
  end

  def eng_unit
    _size = size
    return '' unless _size.to_s =~ /^[0-9]+$/
    if _size >= 10**9
      _kilo = 3
      _unit = 'G'
    elsif _size >= 10**6
      _kilo = 2
      _unit = 'M'
    elsif _size >= 10**3
      _kilo = 1
      _unit = 'K'
    else
      _kilo = 0
      _unit = ''
    end

    if _kilo > 0
      _size = (_size.to_f / (1024**_kilo)).to_s + '000'
      _keta = _size.index('.')
      if _keta == 3
        _size = _size.slice(0, 3)
      else
        _size = _size.to_f * (10**(3-_keta))
        _size = _size.to_f.ceil.to_f / (10**(3-_keta))
      end
    end

    "#{_size}#{_unit}B"
  end

  def reduced_size(options = {})
    return nil unless image?

    src_w  = image_width.to_f
    src_h  = image_height.to_f
    dst_w  = options[:width].to_f
    dst_h  = options[:height].to_f
    src_r    = (src_w / src_h)
    dst_r    = (dst_w / dst_h)
    if dst_r > src_r
      dst_w = (dst_h * src_r);
    else
      dst_h = (dst_w / src_r);
    end

    case options[:output]
    when :css
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    else
      return {:width => dst_w.ceil, :height => dst_h.ceil}
    end
  end
end