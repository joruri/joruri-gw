class Digitallibrary::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Auth
  include Gwboard::Model::Doc::Recognizer
  include Gwboard::Model::Doc::Wiki
  include Digitallibrary::Model::Systemname
  include System::Model::Base::Status

  MAX_SEQ_NO = 999999999.0

  acts_as_tree order: { display_order: :asc, sort_no: :asc }

  has_many :files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :db_files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :recognizers, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :alias_docs, :foreign_key => :doc_alias, :class_name => 'Digitallibrary::Doc'
  belongs_to :aliased_doc, :foreign_key => :doc_alias, :class_name => 'Digitallibrary::Doc'
  belongs_to :control, :foreign_key => :title_id

  has_many :roles, :foreign_key => :title_id, :primary_key => :title_id
  has_one :section, :foreign_key => :code, :primary_key => :section_code, :class_name => 'System::Group'

  has_many :public_children_for_tree, -> { 
    select(:id, :title_id, :parent_id, :level_no, :state, :doc_type, :title, :seq_name).where(state: 'public').order(display_order: :asc, sort_no: :asc)
  }, :foreign_key => :parent_id, :class_name => self.name
  has_many :public_children_for_prev_and_next_link, -> { 
    select(:id, :title_id, :parent_id, :doc_type).where(state: 'public').order(display_order: :asc, sort_no: :asc)
  }, :foreign_key => :parent_id, :class_name => self.name

  after_create :save_name_with_check_digit
  with_options unless: :state_preparation? do |f|
    f.before_validation :set_data_from_aliased_doc
    f.after_save :update_alias_docs
    f.after_save :update_level_no
    f.after_save :update_seq_name
    f.after_destroy :update_seq_name
  end

  validates :state, presence: true
  with_options unless: :state_preparation? do |f|
    f.validates :title, presence: true
    f.validate :validate_if_parent_id_changed
  end

  scope :public_docs, -> { where(state: 'public', doc_type: 1) }
  scope :draft_docs, -> { where(state: 'draft', doc_type: 1) }
  scope :recognizable_docs, -> { where(state: 'recognize', doc_type: 1) }
  scope :recognized_docs, -> { where(state: 'recognized', doc_type: 1) }
  scope :public_docs_and_folders, -> { where(state: 'public') }
  scope :draft_docs_and_folders, -> { where(state: 'draft') }

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:title, :body, params[:kwd]) if params[:kwd].present?
    rel
  }
  scope :index_select, ->(control = nil) {
    select(:id, :title_id, :parent_id, :state, :doc_type, :title, :section_code, :section_name, :seq_name, :display_order, :latest_updated_at)
  }
  scope :index_docs_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when "DRAFT"
      rel = rel.draft_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
    when "RECOGNIZE"
      rel = rel.recognizable_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    when "PUBLISH"
      rel = rel.recognized_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    when "DATE"
      rel = rel.public_docs
    else
      rel = rel.public_docs_and_folders
      rel = rel.where(parent_id: params[:parent_id]) if params[:kwd].blank?
    end
    rel
  }
  scope :index_order_with_params, ->(control, params) {
    case params[:state]
    when 'DATE'
      order(latest_updated_at: :desc, level_no: :asc, display_order: :asc, sort_no: :asc, id: :asc)
    else
      order(level_no: :asc, display_order: :asc, sort_no: :asc, id: :asc)
    end
  }
  scope :preload_public_children_for_prev_and_next_link, -> {
    preload(
      :public_children_for_prev_and_next_link => {
        :public_children_for_prev_and_next_link => {
          :public_children_for_prev_and_next_link => 
            :public_children_for_prev_and_next_link}})
  }
  
  def deletable?
    return false if self.parent_id.blank? && self.level_no == 1 && self.doc_type == 0
    return false unless self.children.blank?
    return true
  end

  def doc_type_folder?
    doc_type == 0
  end

  def doc_type_doc?
    doc_type == 1
  end

  def display_files
    if doc_alias == 0
      files
    else
      aliased_doc ? aliased_doc.files : []
    end
  end

  def no_recog_states
    {'draft' => '下書き保存', 'recognized' => '公開待ち'}
  end

  def recog_states
    {'draft' => '下書き保存', 'recognize' => '承認待ち', 'recognized' => '公開待ち'}
  end

  def ststus_name
    str = ''
    str = '下書き' if self.state == 'draft'
    str = '承認待ち' if self.state == 'recognize'
    str = '公開待ち' if self.state == 'recognized'
    str = '公開中' if self.state == 'public'
    return str
  end

  def doc_alias_options
    options = [["通常の記事として登録する",0]]
    items = control.docs.public_docs.where(doc_alias: 0).select(:id, :seq_name, :title).order(:seq_name)
    items.each do |doc|
      options << ["#{doc.seq_name} #{doc.title}を参照する", doc.id] if doc.id != self.id
    end
    options
  end

  def folder_options
    make_folder_options(control.folders.roots, [])
  end

  def make_folder_options(items, options = [])
    items.each do |item|
      next if item.id == id && !item.root?

      options << if item.id == parent_id
          [item.seq_name, item.id]
        else
          ["#{item.seq_name} <", item.id]
        end
      make_folder_options(item.children.where(doc_type: 0), options)
    end
    options
  end

  def seq_no_items_for_options
    if parent
      parent.children.without_preparation.where(doc_type: self.doc_type)
        .order(level_no: :asc, sort_no: :asc, parent_id: :asc, id: :asc)
    else
      []
    end
  end

  def seq_no_options
    options = []
    seq_no_items_for_options.each do |item|
      options << if item.seq_no == seq_no
          [item.seq_no.to_i.to_s, item.seq_no]
        else
          [item.seq_no.to_i.to_s + 'の前に挿入', item.seq_no - 0.5]
        end
    end
    options << ['最後尾', Digitallibrary::Doc::MAX_SEQ_NO] if options.present?
    options
  end

  def edit_path
    if self.doc_type == 0
      return "#{item_home_path}folders/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id}"
    else
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.parent_id.to_s}" unless self.parent_id.blank?
      return "#{item_home_path}docs/#{self.id}/edit?title_id=#{self.title_id}&cat=#{self.id.to_s}" if self.parent_id.blank?
    end
  end

  def alias_edit_path
    return "#{item_home_path}docs/#{self.doc_alias}/edit?title_id=#{self.title_id}" if self.doc_type == 1
  end

  def link_list_path
    return "#{item_home_path}docs/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def show_folder_path
    return "#{item_home_path}folders/#{self.id}?title_id=#{self.title_id}&cat=#{self.parent_id}" unless self.doc_type == 1   #見出し
    return ret
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def recognize_path
    show_doc_path = "/digitallibrary/docs/#{self.id}?title_id=#{self.title_id}"
    if self.parent_id.blank?
      show_doc_path += "&cat=#{self.id.to_s}&state=RECOGNIZE"
    else
      show_doc_path += "&cat=#{self.parent_id.to_s}&state=RECOGNIZE"
    end
    show_doc_path
  end

  def publish_path
    show_doc_path = "/digitallibrary/docs/#{self.id}?title_id=#{self.title_id}"
    if self.parent_id.blank?
      show_doc_path += "&cat=#{self.id}&state=PUBLISH"
    else
      show_doc_path += "&cat=#{self.parent_id}&state=PUBLISH"
    end
    show_doc_path
  end

  def separator_str
    doc_type_folder? ? control.separator_str1 : control.separator_str2
  end

  def update_level_no_for_descendants
    children.update_all(level_no: self.level_no + 1)
    children.each(&:update_level_no_for_descendants)
  end

  def update_seq_name_for_children
    docc_type_items = children.without_preparation.reorder(:seq_no, :id).partition(&:doc_type_folder?)
    docc_type_items.each do |items|
      items.each.with_index(1) do |item, i|
        seq = if self.seq_name.blank?
            i.to_s
          else
            "#{self.seq_name}#{item.separator_str}#{i}"
          end
        item.update_columns(seq_no: i, order_no: i, sort_no: i + item.doc_type * 1000000000, seq_name: seq)
      end
    end
  end

  def update_seq_name_for_descendants
    update_seq_name_for_children
    children.without_preparation.where(doc_type: 0).reorder(:seq_no, :id).each(&:update_seq_name_for_descendants)
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
  end

  def validate_if_parent_id_changed
    if parent_id != chg_parent_id
      if seq_no != -1 && seq_no != Digitallibrary::Doc::MAX_SEQ_NO
        errors.add :seq_no, "階層が変更になる時は、先頭・最後尾のいずれかを選択してください"
      end 
    end
  end

  def set_data_from_aliased_doc
    if doc_alias.to_i != 0 && aliased_doc
      self.state = aliased_doc.state
      self.body = aliased_doc.body
      self.title = aliased_doc.title if self.title.blank?
    end
  end

  def update_alias_docs
    alias_docs.each do |item|
      item.state = self.state
      item.body = self.body
      item.title = self.title if item.title.blank?
      item.wiki = self.wiki
      item.latest_updated_at = self.latest_updated_at
      item.save
    end
  end

  def update_level_no
    if parent_id_changed?
      parent.update_level_no_for_descendants if parent
    end
  end

  def update_seq_name
    if parent_id_changed? || seq_no_changed? || destroyed?
      if doc_type_folder?
        parent.update_seq_name_for_descendants if parent
      else
        if parent
          parent.update_seq_name_for_children
        end
        if parent_id_was.present? && (parent_was = self.class.find_by(id: parent_id_was))
          parent_was.update_seq_name_for_children
        end
      end
    end
  end
end
