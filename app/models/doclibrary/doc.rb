class Doclibrary::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Auth
  include Gwboard::Model::Doc::Recognizer
  include Gwboard::Model::Doc::Wiki
  include Doclibrary::Model::Systemname
  include Concerns::Doclibrary::Doc::Form001
  include Concerns::Doclibrary::Doc::Form002

  has_many :files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :db_files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :recognizers, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id
  belongs_to :folder, :foreign_key => :category1_id, :touch => true

  has_many :category_files, :foreign_key => :parent_id, :primary_key => :category2_id, :class_name => 'Doclibrary::File'
  belongs_to :category, :foreign_key => :category2_id

  has_many :roles, :foreign_key => :title_id, :primary_key => :title_id
  has_many :folder_acls, :primary_key => :category1_id, :foreign_key => :folder_id
  has_one :section, :foreign_key => :code, :primary_key => :section_code, :class_name => 'System::Group'

  after_create :save_name_with_check_digit
  with_options unless: :state_preparation? do |f|
    f.after_save :update_group_folder_children_size
    f.after_destroy :update_group_folder_children_size
  end

  validates :state, presence: true

  scope :public_docs, -> { where(state: 'public') }
  scope :draft_docs, -> { where(state: 'draft') }
  scope :recognizable_docs, -> { where(state: 'recognize') }
  scope :recognized_docs, -> { where(state: 'recognized') }

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:title, :body, params[:kwd]) if params[:kwd].present?
    case params[:state]
    when 'DATE'
      rel = rel.where(section_code: params[:gcd]) if params[:gcd].present?
      rel = rel.where(category1_id: params[:cat]) if params[:cat].present?
    when 'GROUP'
      rel = rel.where(section_code: control.public_group_folder_descendant_codes(params[:gcd])) if params[:gcd].present?
      rel = rel.where(category1_id: params[:cat]) if params[:cat].present?
    when 'CATEGORY'
      rel = rel.where(section_code: params[:gcd]) if params[:gcd].present?
      rel = rel.where(category1_id: control.public_folder_descendant_ids(params[:cat])) if params[:cat].present? && params[:kwd].present?
      rel = rel.where(category1_id: params[:cat]) if params[:cat].present? && params[:kwd].blank?
    end
    rel
  }
  scope :index_select, ->(control) {
    case control.form_name
    when 'form001'
      select(:id, :title_id, :parent_id, :category1_id, :category2_id, :state, :title, :section_code, :updated_at, :latest_updated_at)
    else
      all
    end
  }
  scope :index_docs_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when "DRAFT"
      rel = rel.draft_docs.in_public_folder
      rel = rel.in_readable_folder(Core.user).group_or_creater_docs(Core.user) unless control.is_admin?
    when "RECOGNIZE"
      rel = rel.recognizable_docs.in_public_folder
      rel = rel.in_readable_folder(Core.user).group_or_recognizer_docs(Core.user) unless control.is_admin?
    when "PUBLISH"
      rel = rel.recognized_docs.in_public_folder
      rel = rel.in_readable_folder(Core.user).group_or_recognizer_docs(Core.user) unless control.is_admin?
    else
      rel = rel.public_docs.in_public_folder
      rel = rel.in_readable_folder(Core.user) unless control.is_admin?
    end
    rel
  }
  scope :index_order_with_params, ->(control, params) {
    case control.form_name
    when 'form001'
      index_order_with_params_form001(control, params)
    else
      index_order_with_params_form002(control, params)
    end
  }

  def display_files
    control.form_name == 'form002' ? category_files : files
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

  def folder_options
    root = control.folders.root
    ([root] + root.readable_public_descendants).map do |folder|
      prefix = '+'
      prefix += "-" * (folder.level_no - 2) if folder.level_no - 2 > 0
      ["#{prefix}#{folder.name}", folder.id]
    end
  end

  def item_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def docs_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def show_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&gcd=#{self.section_code}" if state == 'GROUP'
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.category1_id}&gcd=#{self.section_code}" if state == 'DATE'
    ret = "/doclibrary/docs/#{self.id}/?title_id=#{self.title_id}&cat=#{self.category1_id}" unless state == 'GROUP' unless state == 'DATE'
    return ret
  end

  def edit_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/edit?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def delete_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/delete?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def update_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "/doclibrary/docs/#{self.id}/update?title_id=#{self.title_id}&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/doclibrary/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/doclibrary/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def clone_path
    return "/doclibrary/docs/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def portal_show_path
    s_cat = ''
    s_cat = "&cat=#{self.category1_id}" unless self.category1_id == 0 unless self.category1_id.blank?
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}#{s_cat}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def export_file_path
    s_cat = ''  #更新一覧のリンクは、分類表示のみとする
    s_cat = "&cat=#{self.category1_id}" unless self.category1_id == 0 unless self.category1_id.blank?
    return self.item_home_path + "docs/#{self.id}/export_file?title_id=#{self.title_id}#{s_cat}"
  end

  def file_exports_path
    s_cat = ''  #更新一覧のリンクは、分類表示のみとする
    s_cat = "&cat=#{self.category1_id}" unless self.category1_id == 0 unless self.category1_id.blank?
    return self.item_home_path + "docs/#{self.id}/file_exports?title_id=#{self.title_id}#{s_cat}"
  end

  def compress_category_files(options = {encoding: 'Shift_JIS'})
    file_options = category_files.map {|f| {filename: "#{f.id}_#{f.filename}", filepath: f.f_name} }
    Gw.compress_files(file_options, options)
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
  end

  def update_group_folder_children_size
    folder = control.group_folders.find_by(code: self.section_code)
    return unless folder

    count = control.docs.public_docs.where(section_code: self.section_code).count(:id)
    diff = count - folder.children_size

    folder.children_size = count
    folder.state = folder.children_size == 0 && folder.total_children_size == 0 ? 'closed' : 'public'
    folder.docs_last_updated_at = Time.now unless self.destroyed?
    folder.update_columns(folder.changing_attributes) if folder.changed?

    folder.ancestors.each do |ancestor|
      ancestor.total_children_size += diff
      ancestor.state = ancestor.children_size == 0 && ancestor.total_children_size == 0 ? 'closed' : 'public'
      ancestor.docs_last_updated_at = Time.now unless self.destroyed?
      ancestor.update_columns(ancestor.changing_attributes) if ancestor.changed?
    end
  end
end
