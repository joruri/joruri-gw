class Gwbbs::Comment < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator

  belongs_to :control, :foreign_key => :title_id
  belongs_to :doc, :foreign_key => :parent_id

  validates_presence_of :body

  def editable?(user = Core.user)
    creater_id == user.code || editor_id == user.code
  end

  def deletable?(user = Core.user)
    control.is_admin?(user) || doc.section_code == user.groups.first.try(:code) || editor_id == user.code
  end

  def creater_or_editor_label
    if editordivision.present?
      "#{editordivision} : #{editor}"
    else
      "#{createrdivision} : #{creater}"
    end
  end

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
