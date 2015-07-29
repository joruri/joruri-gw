# -*- encoding: utf-8 -*-
class Cms::Lib::Content::Doc::Base < Cms::Lib::Base
  include Cms::Lib::Content
  include Cms::Lib::Content::Doc::Recognizer
  include Cms::Lib::Content::Doc::Publisher

  attr_accessor :content

  STATES = {1 => '下書き保存', 2 => '承認待ち', 3 => '公開待ち', 4 => '公開中', 5 => '非公開'}

  def condition_to_edit(user_id)
    where("{self}.creator_user_id = ?", user_id)
  end

  def condition_to_recognize(user_id)
    where("{self}.state_no = ?", 2)
    cols = "recognize1_user_id, recognize2_user_id, recognize3_user_id, recognize4_user_id,recognize5_user_id"
    where("? IN (#{cols})", user_id)
  end

  def condition_to_publish(user_id)
    where("{self}.creator_user_id = ?", user_id)
    where("{self}.state_no = ?", 3)
  end

  def condition_in_public
    where("{self}.state_no = ?", 4)
    where("{self}.publish_division_no = ?", 2)
  end

  def condition_in_public_or_own_group(group_id)
    where("{self}.state_no = 4 or {self}.creator_group_id  = ?", group_id)
  end

  def editable?(user_id)
    return true if self.creator_user_id == user_id
    return false
  end

  def openable?(user_id)
    return false unless self.editable?(user_id)
    return true if self.state_no == 3
    return false
  end

  def closable?(user_id)
    return false unless self.editable?(user_id)
    return true if self.state_no == 4
    return false
  end

  def get_doc_dir
    name = self.name
    if name =~ /^[0-9]+$/
      return name.gsub(/^(\d\d)(\d\d)(\d\d)(.*)$/, '\1/\2/\3/\4/\1\2\3\4/')
    else
      return File.join(name.slice(0, 1), name.slice(0, 2), name.slice(0, 3), name)
    end
  end

  def get_upload_path
    return File.join(get_upload_content_path, 'docs', get_doc_dir)
  end

  def get_publish_path
    return File.join(get_publish_content_path, get_doc_dir)
  end

  def get_doc_uri()
    return File.join(get_content_name, self.name, '')
  end

  def get_page_title
    return self.title
  end

  def get_uri(options = {})
    return get_doc_uri
  end

  def get_bread_crumbs(map, options = {})
    map << Cms::ContentMapping.new({:uri => get_uri(:content => options[:content]), :title => get_page_title})
  end

  def recognize
    return false unless _recognize(Site.user.id)
    if self.state_no == 2 && recognized?
      self.state_no = 3
    end
    return save
  end

  def publish(data)
    self.state_no  = 4
    self.published = Core.now unless self.published
    self.closed    = nil

    return false unless save
    publish_files(data)
    return true
  end

  def publish_files(data)
    close_files
    _make_file(File.join(get_publish_path, 'index.html'), data)
    _copy_dir(File.join(get_upload_path, 'files'), File.join(get_publish_path, 'files'))
  end

  def close
    clear_recognition
    self.state_no  = 5
    self.published = nil
    self.closed    = Core.now

    return false unless save
    close_files
    return true
  end

  def close_files
    _remove_dir(File.dirname(get_publish_path))
  end

  def remove_upload_files
    _remove_dir(File.dirname(get_upload_path))
  end

protected
  def after_save
    super
    self.update_attributes({:name => add_check_digit(format("%07d", self.id))}) if self.name.to_s == ""
  end
end