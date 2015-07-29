class Cms::Lib::Content::Doc::Attachment::File::Base < Cms::Lib::Base
  include Cms::Lib::Content
  include Cms::Lib::Content::Doc::Publisher
  include Cms::Lib::FileIcon

  attr_accessor :content, :doc, :attachment
  attr_accessor :file, :file_name

  def before_save
    self.name  = self.file.original_filename
    self.name  = self.file_name if self.file_name.to_s != ''
    self.mime  = self.file.content_type
    self.size  = self.file.size
  end

  def after_save
    _make_file(File.join(get_upload_path, self.name), self.file.read)
  end

  def dependent_condition(attachment_id)
    where("doc_attachment_id = ?", attachment_id)
  end

  def get_upload_path
    return File.join(@doc.get_upload_path, 'files')
  end

  def get(name)
    case name
      when 'urlencoded_title'
        CGI.escape(self.title)
      else
        return super
    end
  rescue ActiveRecord::RecordNotFound
    ''
  end

  def remove_upload_file
    _remove_file(File.join(@doc.get_upload_path, 'files', self.name))
  end
end