class Digitallibrary::Category < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Digitallibrary::Model::Systemname

  acts_as_tree :order=>'sort_no'
  validates_presence_of :state, :name

  def link_list_path
    return "/digitallibrary/adms?parent_id=#{self.id}&title_id=#{self.title_id}"
  end

  def item_path
    return "/digitallibrary/adms?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def show_path
    return "/digitallibrary/adms#{self.id}?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def edit_path
    return "/digitallibrary/adms#{self.id}/edit?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def delete_path
    return "/digitallibrary/adms#{self.id}/delete?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end

  def update_path
    return "/digitallibrary/adms#{self.id}/update?parent_id=#{self.parent_id}&title_id=#{self.title_id}"
  end


end
