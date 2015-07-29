module Cms::Model::Base::Content::Doc::File
  def self.included(mod)
    mod.belongs_to :content, :foreign_key => 'content_id', :class_name => 'Cms::Content'

    mod.before_destroy :remove_upload_file
  end

  def upload_path
    content.upload_path +
      format('%08d', content_id).gsub(/(.*)(..)(..)(..)$/, '/\1/\2/\3/\4') +
      '/' + unid_original.item_type +
      format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '/\1/\2/\3/\4') +
      '/' + name
  end

  def public_path
    File::dirname(doc.public_path) + '/files/' + name
  end

  def public_uri
    File::dirname(doc.public_uri) + 'files/' + name
  end

  def save_with_file(file)
    self.content_type   = file.content_type
    self.content_length = file.size
    return false unless save
    Util::File.put(upload_path, :data => file.read, :mkdir => true)
  end

  def remove_upload_file
    path = upload_path
    File.delete(path) if FileTest.exist?(path)

    begin
      Dir::rmdir(File::dirname(path))
    rescue
      return true
    end
    return true
  end

  def publish
    Util::File.put(public_path, :mkdir => true, :src => upload_path)

    pub                = publisher || System::Publisher.new({:unid => unid})
    pub.published_at   = Core.now
    pub.published_path = public_path
    pub.name           = name
    pub.content_type   = content_type
    pub.content_length = content_length
    pub.save
  end

  def close
    if publisher
      publisher.destroy
      publisher(true)
    end
    return true
  end

  def css_class
    list = {
      'doc'  => 'doc',
      'jtd'  => 'jtd',
      'pdf'  => 'pdf',
      'xls'  => 'xls',
      'xlsx' => 'xls',
    }

    ext = File::extname(name).downcase[1..5]
    if list.key?(ext)
      return 'iconFile icon' + list[ext].gsub(/\b\w/) {|word| word.upcase}
    else
      return 'iconFile'
    end
  end

  def eng_unit
    _size = content_length
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
end