module Cms::Lib::Content
  def dependent_condition(content_id)
    where("{self}.content_id = ?", content_id)
  end
  
  def get_content_name(content = nil)
    content_id = @content ? @content.id : self.content_id
    return Cms::ContentNode.find_by_content_id(content_id).get_uri
  end
  
  def get_upload_content_path
    return File.join(Core.upload_path, 'contents', format('%07d', self.content_id))
  end
  
  def get_publish_content_path
    return File.join(Core.publish_path, get_content_name)
  end
end