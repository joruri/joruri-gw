
require 'rubygems'
require 'kconv'
require 'zipruby'
require 'fileutils'

module Gwcircular::Controller::ZipFileUtils

  def self.zip(src, dest, options = {})
    src = File.expand_path(src)
    dest = File.expand_path(dest)
    File.unlink(dest) if File.exist?(dest)
    Zip::Archive.open(dest,Zip::CREATE) {|zf|
      if(File.file?(src))
        zf.add_file(encode_path(File.basename(src), options[:fs_encoding]), src)
        break
      else
        each_dir_for(src){ |path|
          if File.file?(path)
            zf.add_file(encode_path(relative(path, src), options[:fs_encoding]), path)
          elsif File.directory?(path)
            zf.mkdir(encode_path(relative(path, src), options[:fs_encoding]))
          end
        }
      end
    }
  end


 private
  def self.each_dir_for(dir_path, &block)
    dir = Dir.open(dir_path)
    each_file_for(dir_path){ |file_path|
      yield(file_path)
    }
  end

  def self.each_file_for(path, &block)
    if File.file?(path)
      yield(path)
      return true
    end
    dir = Dir.open(path)
    file_exist = false
    dir.each(){ |file|
      next if file == '.' || file == '..'
      file_exist = true if each_file_for(path + "/" + file, &block)
    }
    yield(path) unless file_exist
    return file_exist
  end

  def self.relative(path, base_dir)
    path[base_dir.length() + 1 .. path.length()] if path.index(base_dir) == 0
  end

  def self.encode_path(path, encode_s)
    return path if encode_s.nil?()
    case(encode_s)
    when('UTF-8')
      return path.toutf8()
    when('Shift_JIS')
      return path.tosjis()
    when('EUC-JP')
      return path.toeuc()
    else
      return path
    end
  end
end