module Gwboard::Model::AttachesFile

  def file_dir
    return "#{Rails.root}/public#{self.file_base_path}"
  end

  def up_dir
    return "#{Rails.root}/upload#{self.file_base_path}"
  end

  def parent_name
    return Util::CheckDigit.check(format('%07d', self.parent_id))
  end

  def filepath
    str = sprintf("%08d",self.id)
    str = "#{str[0..3]}/#{str[4..7]}"
    return "#{self.file_dir}/#{sprintf('%06d',self.title_id)}/#{parent_name}/#{str}/"
  end

  def f_path
    str = sprintf("%08d",self.id)
    str = "#{str[0..3]}/#{str[4..7]}"
    s_path = "#{self.file_dir}"
    s_path = "#{self.up_dir}" if self.content_id == 2
    s_path = "#{self.up_dir}" if self.content_id == 4
    return "#{s_path}/#{sprintf('%06d',self.title_id)}/#{parent_name}/#{str}/"
  end

  def f_name
    ret = "#{filepath}#{self.filename}"
    ret = "#{f_path}#{sprintf("%08d",self.id)}.dat" if self.content_id  == 2
    return ret
  end

  def _upload_file(file)
    @tmp = file
  end

  def file_uri(system_name)
    str = sprintf("%08d",self.id)
    str = "#{str[0..3]}/#{str[4..7]}"

    ret = "#{self.file_base_path}/#{sprintf('%06d',self.title_id)}/#{parent_name}/#{str}/#{URI.encode(self.filename)}"

    ret = "/_admin/gwboard/receipts/#{self.id}/download_object?system=#{system_name}&title_id=#{self.title_id}" if self.content_id  == 2

    if self.content_id  == 3
      ret = "/_admin/_attaches/#{self.system_name}/#{sprintf('%06d',self.title_id)}/#{parent_name}/#{str}/#{URI.encode(self.filename)}"
    end if self.width == 0
    return ret
  end

  def before_create
    self.unid = 2   if self.unid.blank?
    self.width = 0  if self.width.blank?
    self.height = 0 if self.height.blank?
  end

  def after_create
    if self.db_file_id <= 0
      FileUtils.mkdir_p(f_path) unless FileTest.exist?(f_path)
      File.open(f_name, "wb") { |f|
        f.write @tmp.read if self.db_file_id == 0
        f.write @tmp if self.db_file_id == -1
      }

      unless self.content_type.index("image").blank?
        f = open(f_name, "rb")
        r_magick(f.read)
        f.close
      end
    end unless self.db_file_id.blank?
  end

  def r_magick(file)
    begin
    require 'RMagick'
    image = Magick::Image.from_blob(file).shift
    if image.format =~ /(GIF|JPEG|PNG)/
      self.unid = 1
      self.width = image.columns
      self.height = image.rows
    end
    rescue
    end
    save
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

end
