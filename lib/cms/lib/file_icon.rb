module Cms::Lib::FileIcon
  def get_file_icon_class
    ext = File::extname(self.name).downcase[1..5]
    case ext
      when 'xls'
        return _get_file_icon_class(ext)
      when 'xlsx'
        return _get_file_icon_class('xls')
      when 'doc'
        return _get_file_icon_class(ext)
      when 'jtd'
        return _get_file_icon_class(ext)
      when 'pdf'
        return _get_file_icon_class(ext)
      else
        return _get_file_icon_class('default')
    end
  end
  
  def _get_file_icon_class(ext)
    return 'icon ' + ext + 'Icon'
  end
end