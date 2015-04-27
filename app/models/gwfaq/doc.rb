class Gwfaq::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Auth
  include Gwboard::Model::Doc::Recognizer
  include Gwboard::Model::Doc::Wiki
  include Gwfaq::Model::Systemname

  has_many :files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :db_files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :recognizers, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :control, :foreign_key => :title_id
  belongs_to :category, :foreign_key => :category1_id

  has_many :roles, :foreign_key => :title_id, :primary_key => :title_id
  has_one :section, :foreign_key => :code, :primary_key => :section_code, :class_name => 'System::Group'

  after_create :save_name_with_check_digit

  validates :state, presence: true
  with_options unless: :state_preparation? do |f|
    f.validates :title, presence: { message: "を入力してください。" }
    f.validates :category1_id, presence: { message: "を設定してください。" }, if: :category_use?
  end

  scope :public_docs, -> { where(state: 'public') }
  scope :today_public_docs, -> { where(state: 'public').latest_updated_since(Date.today) }
  scope :draft_docs, -> { where(state: 'draft') }
  scope :recognizable_docs, -> { where(state: 'recognize') }
  scope :recognized_docs, -> { where(state: 'recognized') }

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.search_with_text(:title, :body, params[:kwd]) if params[:kwd].present?
    rel = rel.where(category1_id: params[:cat1]) if params[:cat1].present?
    rel = rel.where(category2_id: params[:cat2]) if params[:cat2].present?
    rel = rel.where(category3_id: params[:cat3]) if params[:cat3].present?
    rel = rel.where(section_code: params[:grp]) if params[:grp].present?

    if params[:yyyy].present? && params[:mm].present?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1).beginning_of_day
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1).end_of_day
      rel = rel.where(arel_table[:latest_updated_at].gteq(from_date)).where(arel_table[:latest_updated_at].lteq(to_date))
    end
    rel
  }
  scope :index_select, ->(control = nil) {
    select(:id, :title_id, :category1_id, :state, :title, :section_name, :section_code, :latest_updated_at)
  }
  scope :index_docs_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when "TODAY"
      rel = rel.today_public_docs
    when "DRAFT"
      rel = rel.draft_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
    when "RECOGNIZE"
      rel = rel.recognizable_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    when "PUBLISH"
      rel = rel.recognized_docs
      rel = rel.group_or_recognizer_docs unless control.is_admin?
    else
      rel = rel.public_docs
    end
    rel
  }
  scope :index_order_with_params, ->(control, params) {
    case params[:state]
    when "GROUP"
      order(section_code: :asc, latest_updated_at: :desc)
    when "CATEGORY"
      docs = arel_table
      cats = Gwfaq::Category.arel_table
      order(cats[:sort_no].asc, docs[:category1_id].asc, docs[:title].asc, docs[:latest_updated_at].desc).joins(:category)
    else
      order(latest_updated_at: :desc)
    end
  }

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

  def image_edit_path
    return self.item_home_path + "images?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def upload_edit_path
    return self.item_home_path + "uploads?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def item_path
    return "/gwfaq/docs?title_id=#{self.title_id}"
  end

  def show_path
    return "/gwfaq/docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def edit_path
    return "/gwfaq/docs/#{self.id}/edit?title_id=#{self.title_id}"
  end

  def delete_path
    return "/gwfaq/docs/#{self.id}?title_id=#{self.title_id}"
  end

  def update_path
    return "/gwfaq/docs/#{self.id}/update?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/gwfaq/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/gwfaq/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
  end
end
