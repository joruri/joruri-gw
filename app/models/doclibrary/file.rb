class Doclibrary::File < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::File::Base
  include Doclibrary::Model::Systemname

  belongs_to :doc, :foreign_key => :parent_id
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Doclibrary::Doc'
  belongs_to :control, :foreign_key => :title_id
  belongs_to :db_file, :foreign_key => :db_file_id, :dependent => :destroy

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:filename, params[:kwd]) if params[:kwd].present?
    rel
  }
  scope :index_order_with_params, ->(control, params) {
    case params[:state]
    when 'DATE'
      order(updated_at: :desc, created_at: :desc, filename: :asc)
    when 'GROUP'
      files = arel_table
      docs = Doclibrary::Doc.arel_table
      order(docs[:section_code].asc, docs[:category1_id].asc, files[:updated_at].desc, files[:created_at].desc, files[:filename].asc).joins(:doc)
    else
      order(filename: :asc, updated_at: :desc, created_at: :desc)
    end
  }

  def item_path
    return "/doclibrary/docs?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def item_parent_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    ret = "/doclibrary/docs/#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}" unless state == 'GROUP'
    ret = "/doclibrary/docs/#{self.parent_id}/?title_id=#{self.title_id}&gcd=#{self.parent.section_code}" if state == 'GROUP'
    return ret
  end

  def delete_path
    return "/doclibrary/docs/#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def edit_memo_path(title,item)
    if title.form_name == 'form002'
      return "/doclibrary/docs/#{item.id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
    else
      return "/doclibrary/docs/#{self.parent_id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
    end
  end

  def item_doc_path(title,item)
    if title.form_name=='form002'
      return "/doclibrary/docs/#{item.id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    else
      return "/doclibrary/docs/#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    end
  end

end
