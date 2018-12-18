class Gwbbs::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Auth
  include Gwboard::Model::Doc::Recognizer
  include Gwboard::Model::Doc::ReadFlag
  include Gwboard::Model::Doc::Wiki
  include Gwbbs::Model::Systemname
  include Concerns::Gwbbs::Doc::Form001
  include Concerns::Gwbbs::Doc::Form002
  include Concerns::Gwbbs::Doc::Form003
  include Concerns::Gwbbs::Doc::Form004
  include Concerns::Gwbbs::Doc::Form005
  include Concerns::Gwbbs::Doc::Form006
  include Concerns::Gwbbs::Doc::Form007
  include Concerns::Gwbbs::Doc::Form009

  has_many :files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :db_files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :recognizers, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :comments, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :read_flags, :foreign_key => :parent_id, :class_name => 'Gwbbs::Flag', :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id
  belongs_to :category, :foreign_key => :category1_id

  has_many :comment, :foreign_key => :parent_id, :class_name => 'Gwbbs::Comment'
  has_many :roles, :foreign_key => :title_id, :primary_key => :title_id
  has_one :section, :foreign_key => :code, :primary_key => :section_code, :class_name => 'System::Group'
  has_many :comments_only_id, -> { select(:id, :parent_id).order(:id) }, :foreign_key => :parent_id, :class_name => 'Gwbbs::Comment'

  after_create :save_name_with_check_digit
  with_options unless: :state_preparation? do |f|
    f.after_save :update_doc_body_size_currently
    f.after_destroy :update_doc_body_size_currently
  end

  validates :state, presence: true
  validates :able_date, presence: true
  validates :expiry_date, presence: true
  with_options unless: :state_preparation? do |f|
    f.validates :category1_id, presence: { message: "を設定してください。" }, if: :category_use?
    f.validates :section_code, presence: { message: "記事管理課を選択してください。" }
    f.validate :validate_body_size_limit
    f.validate :validate_able_date_and_expiry_date
  end

  scope :public_docs, ->(time = Time.now) {
    where(state: 'public').where(arel_table[:able_date].lteq(time)).where(arel_table[:expiry_date].gteq(time))
  }
  scope :prepublic_docs, ->(time = Time.now) {
    where(state: 'public').where(arel_table[:able_date].gteq(time))
  }
  scope :expired_docs, ->(time = Time.now) {
    where(state: 'public').where(arel_table[:expiry_date].lteq(time))
  }
  scope :draft_docs, -> { where(state: 'draft') }
  scope :recognizable_docs, -> { where(state: 'recognize') }
  scope :recognized_docs, -> { where(state: 'recognized') }

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:title, :body, params[:kwd]) if params[:kwd].present?
    rel = rel.where(category1_id: params[:cat1]) if params[:cat1].present?
    rel = rel.where(category2_id: params[:cat2]) if params[:cat2].present?
    rel = rel.where(category3_id: params[:cat3]) if params[:cat3].present?
    rel = rel.where(inpfld_006w: params[:yyyy]) if control.form_name == 'form006' && params[:yyyy].present?

    if params[:grp].present?
      case control.form_name
      when 'form006', 'form007'
        rel = rel.where(inpfld_002: params[:grp])
      else
        rel = rel.where(section_code: params[:grp])
      end
    end

    if params[:yyyy].present? && params[:mm].present?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1).beginning_of_day
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1).end_of_day
      rel = rel.where(arel_table[:latest_updated_at].gteq(from_date)).where(arel_table[:latest_updated_at].lteq(to_date))
    end
    rel
  }
  scope :index_select, ->(control) {
    case control.form_name
    when 'form001'
      select(:id, :title_id, :category1_id, :state, :title, :section_name, :section_code, :importance, :attachmentfile, :one_line_note, :createdate, :latest_updated_at, :created_at)
    else
      all
    end
  }
  scope :index_docs_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when "DRAFT"
      rel = rel.draft_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
    when "NEVER"
      rel = rel.prepublic_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
    when "VOID"
      rel = rel.expired_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
    when "RECOGNIZE"
      rel = rel.recognizable_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    when "PUBLISH"
      rel = rel.recognized_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    else
      rel = rel.public_docs
      rel = rel.group_or_creater_docs if !control.is_admin? && control.restrict_access
    end
    rel
  }
  scope :index_order_with_params, ->(control, params) {
    case control.form_name
    when 'form006'
      index_order_with_params_form006(control, params)
    else
      index_order_with_params_common(control, params)
    end
  }
  scope :index_order_with_params_common, ->(control, params) {
    case params[:state]
    when "GROUP"
      order(section_code: :asc, latest_updated_at: :desc)
    when "CATEGORY"
      docs = Gwbbs::Doc.arel_table
      cats = Gwbbs::Category.arel_table
      order(cats[:sort_no].asc, docs[:category1_id].asc, docs[:latest_updated_at].desc).joins(:category)
    else
      order(latest_updated_at: :desc)
    end
  }

  def importance_states
    {'0' => '重要必読', '1' => '普通'}
  end

  def importance_states_select
    return [
      ['重要必読', 0] ,
      ['普通', 1]
    ]
  end

  def one_line_states
    return [
      ['使用しない', 0] ,
      ['使用する', 1]
    ]
  end

  def no_recog_states
    {'draft' => '下書き保存', 'recognized' => '公開待ち'}
  end

  def recog_states
    {'draft' => '下書き保存', 'recognize' => '承認待ち', 'recognized' => '公開待ち'}
  end

  def family_states
    {'0' => '家族', '1' => '職員'}
  end

  def ststus_name
    str = ''
    str = '下書き' if self.state == 'draft'
    str = '承認待ち' if self.state == 'recognize'
    str = '公開待ち' if self.state == 'recognized'
    str = '公開中' if self.state == 'public'
    str = '期限切れ' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    return str
  end

  def importance_name
    return self.importance_states[self.importance.to_s]
  end

  def new_comment_path
    return self.item_home_path + "comments/new?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def image_edit_path
    return self.item_home_path + "images?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def upload_edit_path
    return self.item_home_path + "uploads?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def item_path
    return "/gwbbs/docs?title_id=#{self.title_id}"
  end

  def show_path
    return "/gwbbs/docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def edit_path
    return "/gwbbs/docs/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/gwbbs/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/gwbbs/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def clone_path
    return "/gwbbs/docs/#{self.id}/clone/?title_id=#{self.title_id}"
  end
  #
  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def delete_path
    return "/gwbbs/docs/#{self.id}/delete?title_id=#{self.title_id}"
  end

  def update_path
    #return "/_admin/gwbbs/docs/#{self.id}/update?title_id=#{self.title_id}"
    return "/gwbbs/docs/#{self.id}?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def export_file_path
    return self.item_home_path + "docs/#{self.id}/export_file/?title_id=#{self.title_id}"
  end

  def file_exports_path
    return self.item_home_path + "docs/#{self.id}/file_exports/?title_id=#{self.title_id}"
  end

  def new_mark_flg
    new_mark_end = Time.parse(self.createdate) + 1.days
    Time.now <= new_mark_end
  rescue
    false
  end

  def hcs_link_target?
    group_codes = Joruri.config.application['gwbbs.hcs_group_codes'].presence || []
    category_ids = Joruri.config.application['gwbbs.hcs_category_ids'].presence || []

    title_id == 1 && state == 'public' && (category_ids.index(category1_id) || group_codes.index(section_code))
  end

  def duplicate
    new_doc = self.class.new
    new_doc.attributes = self.attributes.except("id")
    new_doc.unid = nil
    new_doc.created_at = nil
    new_doc.updated_at = nil
    new_doc.recognized_at = nil
    new_doc.published_at = nil
    new_doc.state = 'draft'
    new_doc.category4_id = 0
    new_doc.name = nil
    new_doc.latest_updated_at = Core.now
    new_doc.createdate = nil
    new_doc.creater_admin = nil
    new_doc.createrdivision_id = nil
    new_doc.createrdivision = nil
    new_doc.creater_id = nil
    new_doc.creater = nil
    new_doc.editdate = nil
    new_doc.editor_admin = nil
    new_doc.editordivision_id = nil
    new_doc.editordivision = nil
    new_doc.editor_id = nil
    new_doc.editor = nil
    new_doc.able_date = Time.now.strftime("%Y-%m-%d")
    new_doc.expiry_date = control.default_published.months.since.strftime("%Y-%m-%d")
    new_doc.section_code = Core.user_group.code
    new_doc.section_name = Core.user_group.code + Core.user_group.name

    return nil unless new_doc.save

    files.each do |file|
      new_file = file.class.new
      new_file.attributes = file.attributes.except("id")
      new_file.file = Sys::Lib::File::NoUploadedFile.new(file.f_name, filename: file.filename, mime_type: file.content_type)
      new_file.parent_id = new_doc.id
      new_file.db_file_id = -1
      new_file.save!

      new_doc.body = new_doc.body.gsub(file.file_uri('gwbbs'), new_file.file_uri('gwbbs'))
    end

    new_doc.update_columns(body: new_doc.body) if new_doc.body_changed?
    new_doc
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
  end

  def validate_able_date_and_expiry_date
    if self.able_date && self.expiry_date && self.able_date > self.expiry_date
      errors.add :able_date, "を確認してください。（期限日が公開日より前になっています。）"
      errors.add :expiry_date, "を確認してください。（期限日が公開日より前になっています。）"
    end
  end

  def validate_body_size_limit
    if self.body.present?
      body_size_capacity = 0
      body_size_currently = 0
      body_size_capacity = control.doc_body_size_capacity.megabytes unless control.doc_body_size_capacity.blank?
      body_size_currently = control.doc_body_size_currently unless control.doc_body_size_currently.blank?
      body_size_currently = body_size_currently + self.body.size
      if body_size_capacity != 0 && body_size_capacity < body_size_currently
        errors.add :title, "記事本文の容量制限を#{body_size_currently - body_size_capacity}バイト超過しました。　不要な記事を削除するか、管理者に連絡してください。"
      end
    end
  end

  def set_creater_editor
    super(force_create: self.editdate.blank? && self.state_was == 'draft')

    if self.able_date && self.able_date > Time.now
      self.createdate = self.able_date.strftime("%Y-%m-%d %H:%M")
      self.creater_id = Core.user.code
      self.creater = Core.user.name
      self.createrdivision = Core.user_group.name
      self.createrdivision_id = Core.user_group.code
      self.editor_id = Core.user.code
      self.editordivision_id = Core.user_group.code
      self.creater_admin = control.is_admin?
      self.editor_admin = control.is_admin?
      self.editdate = ''
      self.editor = ''
      self.editordivision = ''
      self.latest_updated_at = self.able_date
    end
  end

  def update_doc_body_size_currently
    total_size = Gwbbs::Doc.where(title_id: title_id).group(:title_id).sum("LENGTH(`body`)").values[0].to_i
    control.update_columns(doc_body_size_currently: total_size)
  end
end
