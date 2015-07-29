module Cms::Lib::Content::Doc::Publisher
protected
  def _make_dir(path)
    FileUtils.mkdir_p(path) unless FileTest.exist?(path)
  end
  
  def _copy_dir(fr, to)
    FileUtils.copy_entry(fr, to) if FileTest.exist?(fr)
  end
  
  def _remove_dir(path)
    return true unless FileTest.exist?(path)
    return FileUtils.remove_entry(path)    
  end
  
  def _make_file(path, data)
    _make_dir(File.dirname(path))
    fp = File.open(path, 'w')
    fp.puts data
    fp.close
  end
  
  def _remove_file(path)
    return true unless FileTest.exist?(path)
    return File.delete(path)
  end
end