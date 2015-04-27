class Doclibrary::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Doclibrary::Model::Systemname
  include System::Model::Base::Status

  #has_many :adm, :foreign_key => :title_id, :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs, :foreign_key => :title_id, :dependent => :destroy
  has_many :folders, :foreign_key => :title_id, :dependent => :destroy
  has_many :group_folders, :foreign_key => :title_id, :dependent => :destroy
  has_many :categories, :foreign_key => :title_id, :dependent => :destroy
  has_many :files, :foreign_key => :title_id

  after_save :set_root_folder

  validates :state, :title, :category1_name, presence: true
  validates :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def get_readable_folder_ids(state,grp_codes,user_code, is_admin)
    cond_arr = []
    cond_str = "(state = ? AND doclibrary_folders.title_id = ?) AND ((acl_flag = 0)"
    if is_admin
      cond_str += " OR (acl_flag = 9))"
      cond_arr = [cond_str, state, self.id]
    else
      cond_str  += " OR (acl_flag = 1 AND acl_section_code in (?))"
      cond_str  += " OR (acl_flag = 2 AND acl_user_code = ?))"
      cond_arr = [cond_str, state, self.id, grp_codes,user_code]
    end
    select_str = "doclibrary_folders.id, parent_id, state, doclibrary_folders.created_at, doclibrary_folders.updated_at, doclibrary_folders.title_id, sort_no, level_no, name, acl_flag, acl_section_code, acl_user_code"
    folders = Doclibrary::Folder.where(cond_arr).joins(:folder_acls).select(select_str).order(:sort_no)
    folder_ids = folders.map{|f| f.id}
    return folder_ids
  end

  def doclib_form_name
    return 'doclibrary/admin/user_forms/' + self.form_name + '/'
  end

  def use_form_name
    [['一般書庫','form001'], ['議案検索DB','form002']]
  end

  def doc_section_code_options(state = 'public')
    section_codes = docs.select(:section_code).where(state: state).group(:section_code).map(&:section_code)
    System::Group.select(:code, :name).where(code: section_codes).order(:sort_no, :code).map{|g| [g.name, g.code]}
  end

  def readable_public_folder_options
    folders.root.self_and_readable_public_descendant_options
  end

  def public_group_folder_descendant_codes(gcode)
    codes = [gcode]
    if gf = group_folders.where(code: gcode).first
      codes += gf.public_descendant_codes
    end
    codes
  end

  def public_folder_descendant_ids(id)
    ids = [id]
    if f = folders.where(id: id).first
      ids += f.public_descendant_ids
    end
    ids
  end

  def special_link_gwbbs_control
     return @special_link_gwbbs_control if defined? @special_link_gwbbs_control
     opts = special_link.to_s.split(',')
     @special_link_gwbbs_control = opts[2].present? ? Gwbbs::Control.find_by(id: opts[2]) : nil
  end

  def menu_item_path
    "/doclibrary/doc?title_id=#{self.id}"
  end

  def group_folders_path
    "/doclibrary/" + "group_folders?title_id=#{self.id}"
  end

  def categorys_path
    "/doclibrary/" + "categories?title_id=#{self.id}"
  end

  def new_uploads_path
    "/doclibrary/" + "docs/new?title_id=#{self.id}"
  end

  def docs_path
    "/doclibrary/" + "docs?title_id=#{self.id}"
  end

  def adm_docs_path
    "/doclibrary/" + "adms?title_id=#{self.id}"
  end

  def date_index_display_states
    {'0' => '使用する', '1' => '使用しない'}
  end

  private

  def set_root_folder
    if root = folders.root
      root.update_columns(name: self.category1_name) if self.category1_name_changed?
    else
      folders.create(
        :state => 'public',
        :parent_id => nil,
        :sort_no => 0,
        :level_no => 1,
        :name => self.category1_name,
        :reader_groups_json => '[]',
        :readers_json => '[]'
      )
    end
  end
end
