# encoding: utf-8
class Sys::Lib::Mail::Attachment
  attr_reader :seqno
  attr_reader :content_type
  attr_reader :name
  attr_reader :body
  attr_reader :size
  attr_reader :transfer_encoding
  
  def initialize(attributes = {})
    attributes.each {|name, value| eval("@#{name} = value")}
  end
  
  def image?
    @content_type =~ /^image/i ? true : false
  end
  
  def image_width
    return nil unless image?
    begin
      require 'RMagick'
      image = Magick::Image.from_blob(data).shift
      if image.format =~ /(GIF|JPEG|PNG)/
        @image_width = image.columns
        @image_height= image.rows
      end
    rescue => e
    end
    @image_width
  end
  
  def image_height
    return nil unless image_width
    @image_height
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
    
    if options[:css]
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    end
    return {:width => dst_w.ceil, :height => dst_h.ceil}
  end
  
  def thumbnail(options)
    begin
      require 'RMagick'
      image = Magick::Image.from_blob(@body).shift
      raise 'NotImage' unless image.format =~ /(GIF|JPEG|PNG|BMP)/
      src_w = image.columns.to_f
      src_h = image.rows.to_f
      dst_w = options[:width].to_f
      dst_h = options[:height].to_f
      if src_w > dst_w || src_h > dst_h
        src_r = (src_w / src_h)
        dst_r = (dst_w / dst_h)
        if dst_r > src_r
          dst_w = (dst_h * src_r);
        else
          dst_h = (dst_w / src_r);
        end
        image.format = options[:format].to_s if options[:format]
        image.thumbnail!(dst_w.ceil, dst_h.ceil)
      end
      return image.to_blob { self.quality = options[:quality] if options[:quality] }
    rescue => e
      return nil
    end
  end
  
  def css_class
    if ext = File::extname(@name).downcase[1..5]
      conv = {
        'xlsx' => 'xls',
      }
      ext = conv[ext] if conv[ext]
      ext = ext.gsub(/[^0-9a-z]/, '')
      return 'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    end
    return 'iconFile'
  rescue
    return 'iconFile'
  end
  
  def eng_unit
    return @eng_unit if @eng_unit
    @eng_unit = "#{Util::Unit.eng_unit(@size, "Bytes")}"
  end
end