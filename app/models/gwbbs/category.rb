class Gwbbs::Category < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwbbs::Model::Systemname


  acts_as_tree :order=>'sort_no'
  validates_presence_of :state, :sort_no, :name

  def max_line
    return 30
  end

  def link_list_path
    return "#{Core.current_node.public_uri}?title_id=#{self.title_id}"
  end

  def item_path
    return "#{Core.current_node.public_uri}?title_id=#{self.title_id}"
  end

  def show_path
    return "#{Core.current_node.public_uri}#{self.id}?title_id=#{self.title_id}"
  end

  def edit_path
    return "#{Core.current_node.public_uri}#{self.id}/edit?title_id=#{self.title_id}"
  end

  def delete_path
    return "#{Core.current_node.public_uri}#{self.id}/delete?title_id=#{self.title_id}"
  end

  def update_path
    return "#{Core.current_node.public_uri}#{self.id}/update?title_id=#{self.title_id}"
  end


  def is_deletable?
    cnt = Gwbbs::Doc.where(:category1_id=>self.id).count
    return false if cnt > 0
    return true
  end

end
