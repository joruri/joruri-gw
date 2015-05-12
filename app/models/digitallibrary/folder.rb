class Digitallibrary::Folder < Digitallibrary::Doc
  acts_as_tree order: { display_order: :asc, sort_no: :asc }

  has_many :docs, -> { where(doc_type: 1) }, :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id

  def folder_editable?
    return false if self.parent_id.blank? && self.level_no == 1 && self.doc_type == 0
    return true
  end

  def status_select
    [['公開','public'], ['非公開','closed']]
  end

  def status_name
    {'public' => '公開', 'closed' => '非公開'}
  end

  def link_list_path
    return "#{item_home_path}docs/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def show_folder_path
    return "#{item_home_path}folders/#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id}" unless self.doc_type == 1   #見出し
  end

  def edit_path
    if self.doc_type == 0
      return "#{item_home_path}folders/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id}"
    else
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    end
  end

  def delete_path
    if self.doc_type == 0
      return "#{item_home_path}folders/#{self.id}/delete?title_id=#{self.title_id}&cat=#{self.parent_id}"
    else
      return "#{item_home_path}docs/#{self.id}/delete?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
      return "#{item_home_path}docs/#{self.id}/delete?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    end
  end
end
