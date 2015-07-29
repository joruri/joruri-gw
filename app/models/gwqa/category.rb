class Gwqa::Category < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwqa::Model::Systemname

  acts_as_tree :order=>'sort_no'

  validates_presence_of :state, :sort_no, :name

  def link_list_path
    return "#{Site.current_node.public_uri}?parent_id=#{self.id}&title_id=#{self.title_id}"
  end

  def item_path
    return "#{Site.current_node.public_uri}?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def show_path
    return "#{Site.current_node.public_uri}#{self.id}?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def edit_path
    return "#{Site.current_node.public_uri}#{self.id}/edit?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}/update?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end


  def is_deletable?
    cnt = Gwqa::Doc.where(:category1_id=>self.id).count
    return false if cnt > 0
    return true
  end
end
