class Gwbbs::Comment < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :doc,   :foreign_key => :parent_id,     :class_name => 'Gwbbs::Doc'

  validates_presence_of :body

  def item_path
    return "/gwbbs/docs/#{self.parent_id}?title_id=#{self.title_id}"
  end

  def item_home_path
    return '/_admin/gwbbs/comments/'
  end

  def edit_comment_path
    return self.item_home_path + "#{self.id}/edit?title_id=#{self.title_id}"
  end

  def show_comment_path
    return self.item_home_path + "#{self.id}/?title_id=#{self.title_id}"
  end

  def update_comment_path
    return self.item_home_path + "#{self.id}?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def delete_comment_path
    return self.item_home_path + "#{self.id}?title_id=#{self.title_id}"
  end

end
