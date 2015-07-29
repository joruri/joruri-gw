# -*- encoding: utf-8 -*-

module Gwboard::Model::AttachFile

  def is_image
    if self.unid == 1
      return true
    else
      return false
    end
  end

  def is_big_width(dst_w=nil)
    dst_w = 720.to_f if dst_w.blank?
    ret = false
    ret = true if dst_w < self.width.to_f
    return ret
  end

  def regulate_size(dst_w=nil)
    dst_w = 720.to_f if dst_w.blank?
    src_w  = self.width.to_f
    src_h  = self.height.to_f
    unless src_w == 0
      src_r  = (dst_w / src_w)
      dst_h = src_h * src_r
    else
      dst_w = 0
      dst_h = 0
    end
    return {:width => dst_w.ceil, :height => dst_h.ceil}
  end

  def graphic_size
    str = ''
    str = "<br />（#{self.width.to_s} x #{self.height.to_s}）" if self.unid == 1
    return str
  end

  def gwbd_reduced_size(options = {})
    return nil unless self.unid == 1

    src_w  = self.width.to_f
    src_h  = self.height.to_f
    dst_w  = options[:width].to_f
    dst_h  = options[:height].to_f
    unless src_h == 0
      src_r    = (src_w / src_h)
      dst_r    = (dst_w / dst_h)
      if dst_r > src_r
        dst_w = (dst_h * src_r);
      else
        dst_h = (dst_w / src_r);
      end
    else
      dst_w = 0
      dst_h = 0
    end

    case options[:output]
    when :css
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    else
      return {:width => dst_w.ceil, :height => dst_h.ceil}
    end
  end

  def icon_type
    str = self.filename.to_s
    l = 0
    l = str.length
    ext = ''
    if l != 0
      i = str.rindex ".", l
      ext = str[i+ 1,l] unless i == nil
      ext = ext.downcase
      case ext
      when "bmp", "csv", "doc", "exe", "gif", "jpg", "jtd", "lzh", "pdf", "png", "ppt", "txt", "vbs", "xls", "zip",
           "odb", "odf", "odg", "odp", "ods", "odt", "otp", "ott", "ots", "odg", "otg" then
        ext = 'icon' + ext.capitalize
      end
    end
    return 'iconFile ' + ext
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

    src_w  = width.to_f
    src_h  = height.to_f
    dst_w  = options[:width].to_f
    dst_h  = options[:height].to_f
    unless src_h == 0
      src_r    = (src_w / src_h)
      dst_r    = (dst_w / dst_h)
      if dst_r > src_r
        dst_w = (dst_h * src_r);
      else
        dst_h = (dst_w / src_r);
      end
    else
      dst_w = 0
      dst_h = 0
    end

    case options[:output]
    when :css
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    else
      return {:width => dst_w.ceil, :height => dst_h.ceil}
    end
  end

  def image_delete_all(root)
    path = root + sprintf("%06d",self.id) + "/"
    deleteall(path)
  end

  def deleteall(delthem)
    if FileTest.directory?(delthem) then
      Dir.foreach( delthem ) do |file|
        next if /^\.+$/ =~ file
        deleteall( delthem.sub(/\/+$/,"") + "/" + file )
      end
      Dir.rmdir(delthem) rescue ""
    else
      File.delete(delthem)
    end
  end


end
