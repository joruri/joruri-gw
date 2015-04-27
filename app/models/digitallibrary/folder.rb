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

  def ststus_name
    str = ''
    str = '下書き' if self.state == 'draft'
    str = '承認待ち' if self.state == 'recognize'
    str = '公開待ち' if self.state == 'recognized'
    str = '公開中' if self.state == 'public'
    return str
  end

  def link_list_path
    return "#{item_home_path}docs/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def item_path
    return "#{Site.current_node.public_uri}?title_id=#{self.title_id}&cat=#{self.parent_id}"
  end

  def show_path
    ret = "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}&cat=#{self.id}" if self.doc_type == 1              #記事
    ret = "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id}" unless self.doc_type == 1   #見出し
    return ret
  end

  def show_folder_path
    return "#{item_home_path}folders/#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id}" unless self.doc_type == 1   #見出し
  end

  def docs_path
    ret = "#{Site.current_node.public_uri}?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    ret = "#{Site.current_node.public_uri}?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
    return ret
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

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}/update?title_id=#{self.title_id}&cat=#{self.parent_id}"
  end

  def child_count
    file_base  = Digitallibrary::Doc.new
    file_cond  = "state!='preparation' and parent_id=#{self.id} and doc_type=1"
    file_count = file_base.count(:all,:conditions=>file_cond)

    folder_base = Digitallibrary::Folder.new
    folder_cond = "state!='preparation' and parent_id=#{self.id} and doc_type=0"
    folder_count  = folder_base.count(:all,:conditions=>folder_cond)

    child_count =file_count + folder_count
    return child_count
  end
end
