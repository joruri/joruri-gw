# -*- encoding: utf-8 -*-
class Digitallibrary::File < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Digitallibrary::Model::Systemname
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Doclibrary::Doc'

  validates_presence_of :filename, :message => "ファイルが指定されていません。"

  before_create :before_create
  after_create :after_create
  after_destroy :after_destroy

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        and_keywords v, :filename
      end
    end if params.size != 0

    return self
  end

  def edit_memo_path(title,item)
    return "/digitallibrary/docs/#{self.parent_id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
  end

  def item_path
    return "/digitallibrary/docs?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def delete_path
    return "/digitallibrary/docs/#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def item_doc_path(title,item)
    return "/digitallibrary/docs/#{self.parent_id}?title_id=#{self.title_id}"
  end

end
