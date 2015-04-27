class Gwbbs::File < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::File::Base
  include Gwbbs::Model::Systemname

  belongs_to :doc, :foreign_key => :parent_id
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Gwbbs::Doc'
  belongs_to :control, :foreign_key => :title_id
  belongs_to :db_file, :foreign_key => :db_file_id, :dependent => :destroy

  def item_path
    return "/gwbbs/docs?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def edit_memo_path(title,item)
    return "/gwbbs/docs/#{self.parent_id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
  end

  def item_parent_path
    return "/gwbbs/docs/#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
  end

  def item_doc_path(title,item)
    return "/gwbbs/docs/#{self.parent_id}?title_id=#{self.title_id}"
  end

  def delete_path
    return "/gwbbs/docs/#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end
end
