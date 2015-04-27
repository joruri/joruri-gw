class Doclibrary::Folder < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Folder::Auth
  include Doclibrary::Model::Systemname

  acts_as_tree order: { sort_no: :asc }, :dependent => :destroy

  has_many :docs, :foreign_key => :category1_id, :dependent => :destroy
  has_many :folder_acls, :foreign_key => :folder_id, :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id

  before_save :sync_to_parent_readers_and_reader_groups
  before_save :sync_to_parent_state
  after_save :update_level_no
  after_save :close_folders_and_docs

  validates :state, :name, presence: true

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:name, params[:kwd]) if params[:kwd].present?
    rel
  }
  scope :index_folders_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when 'DRAFT'
      rel = rel.where(state: 'closed')
    else
      rel = rel.where(state: 'public').where(parent_id: params[:cat])
    end
    rel = rel.with_readable_acl(control, Core.user).joins(:folder_acls) unless control.is_admin?
    rel
  }

  def status_select
    [['公開','public'], ['非公開','closed']]
  end

  def status_name
    {'public' => '公開', 'closed' => '非公開'}
  end

  def editable?
    !root?
  end

  def deletable?
    !root?
  end

  def parent_options
    root = control.folders.root
    ([root] + root.readable_public_descendants(control, without: self.id)).map do |folder|
      prefix = '+'
      prefix += "-" * (folder.level_no - 2) if folder.level_no - 2 > 0
      ["#{prefix}#{folder.name}", folder.id]
    end
  end

  def link_list_path
    return "#{self.item_home_path}docs?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.id}"
  end

  def item_path
    return "#{self.item_home_path}folders?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def show_path
    return "#{self.item_home_path}folders/#{self.id}?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def edit_path
    return "#{self.item_home_path}folders/#{self.id}/edit?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def delete_path
    return "#{self.item_home_path}folders/#{self.id}?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def update_path
    return "#{self.item_home_path}folders/#{self.id}/update?title_id=#{self.title_id}&state=CATEGORY&cat=#{self.parent_id}"
  end

  def public_children
    children.where(state: 'public')
  end

  def public_descendants
    public_children.inject([]) {|arr, c| arr << c; arr += c.public_descendants }
  end

  def public_descendant_ids
    public_children.select(:id, :parent_id).inject([]) do |arr, c|
      arr << c.id
      arr += c.public_descendant_ids
    end
  end

  def self_and_readable_public_descendant_options
    ([self] + readable_public_descendants).map {|c| ["+" + "-"*(c.level_no - 1) + c.name, c.id] }
  end

  def readable_public_descendants(ctrl = control, options = {})
    public_children.with_readable_acl(ctrl).inject([]) do |arr, c|
      next arr if options[:without] && options[:without] == c.id
      arr << c
      arr += c.readable_public_descendants(ctrl)
    end
  end

  def enabled_children
    folders = self.class.new.find(:all, :conditions=>["parent_id = ? AND state = ? AND doclibrary_folders.title_id = ?", self.id, "public", self.title_id], :joins=>:folder_acls,
      :select => 'doclibrary_folders.id, parent_id, state, doclibrary_folders.created_at, doclibrary_folders.updated_at, doclibrary_folders.title_id, sort_no, level_no, name, acl_flag, acl_section_code, acl_user_code',
      :order=>"sort_no")
  end

  def count_children
    folders = self.class.where(:parent_id => self.id, :title_id => self.title_id).order('sort_no').count
  end

  def update_level_no_for_descendants
    children.update_all(level_no: self.level_no + 1)
    children.each(&:update_level_no_for_descendants)
  end

  def close_folders_and_docs_for_descendants
    docs.without_preparation.update_all(state: 'draft')
    children.update_all(state: 'closed')
    children.each(&:close_folders_and_docs_for_descendants)
  end

  private

  def sync_to_parent_readers_and_reader_groups
    return unless parent
    self.readers_json = parent.readers_json if self.readers_json.blank? && !parent.readers_json.blank?
    self.reader_groups_json = parent.reader_groups_json if self.reader_groups_json.blank? && !parent.reader_groups_json.blank?
  end

  def sync_to_parent_state
    return unless parent
    self.state = 'closed' if parent.state == 'closed'
  end

  def update_level_no
    if parent_id_changed? && parent
      parent.update_level_no_for_descendants
    end
  end

  def close_folders_and_docs
    if state_changed? && state == 'closed'
      close_folders_and_docs_for_descendants
    end
  end
end
