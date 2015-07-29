module Cms::Model::Base::Content::Doc::Image
  def self.included(mod)
    mod.belongs_to :content, :foreign_key => 'content_id', :class_name => 'Cms::Content'

    mod.before_destroy :remove_upload_image
  end

  def upload_path
    content.upload_path +
      format('%08d', content_id).gsub(/(.*)(..)(..)(..)$/, '/\1/\2/\3/\4') +
      '/' + unid_original.item_type +
      format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '/\1/\2/\3/\4') +
      '/' + name
  end

  def public_path
    File::dirname(doc.public_path) + '/images/' + name
  end

  def public_uri
    File::dirname(doc.public_uri) + 'images/' + name
  end

  def save_with_file(file)
    self.content_type   = file.content_type
    self.content_length = file.size
    return false unless save
    Util::File.put(upload_path, :data => file.read, :mkdir => true)
  end

  def remove_upload_image
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
end