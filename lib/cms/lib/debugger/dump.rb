class Cms::Lib::Debugger::Dump
  @@dumped = false
  
  def self.execute(data)
    put_log to_str(data)
  end
  
  def self.to_str(data, dep = 1)
    buf = ''
    if (data.class == Array)
      buf += 'Array ('
      data.each_with_index {|v,k| buf += "\n" + sp(dep) + k.to_s + ' => ' + to_str(v, dep + 1) }
      buf += "\n" + sp(dep - 1) + ')'
    elsif (data.class == HashWithIndifferentAccess || data.class == Hash)
      buf += 'Hash ('
      data.each {|k,v| buf += "\n" + sp(dep) + k.to_s + ' => ' + to_str(v, dep + 1) }
      buf += "\n" + sp(dep - 1) + ')'
    else
      buf += data.to_s + ' <' + data.class.to_s + '>'
    end
    return buf
  end
  
  def self.sp(num)
    s = ''
    num.times { s += '    ' }
    return s
  end
  
  def self.put_log(data)
    log = __FILE__.gsub(/\\/, '/').gsub('lib/cms/lib/debugger/dump.rb', 'log/dump.log')
    
    f = File.open(log, 'a')
    f.flock(File::LOCK_EX)
    unless @@dumped
      f.puts "\n" + '====================='
      f.puts Time.now.strftime(' %Y-%m-%d %H:%M:%S')
      f.puts '=====================' + "\n\n"
      @@dumped = true
    else
      f.puts '--'
    end
    f.puts data
    f.flock(File::LOCK_UN)
    f.close
  end
end
