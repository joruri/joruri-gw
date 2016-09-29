class Gwqa::Doc < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Gwboard::Model::Doc::Base
  include Gwboard::Model::Doc::Auth
  include Gwboard::Model::Doc::Wiki
  include Gwqa::Model::Systemname

  has_many :files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :images, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :db_files, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :recognizers, -> { order(:id) }, :foreign_key => :parent_id, :dependent => :destroy
  has_many :answers, -> { where(doc_type: 1).order(:id) }, :foreign_key => :parent_id, :dependent => :destroy, :class_name => 'Gwqa::Doc'
  belongs_to :question, -> { where(arel_table[:doc_type].eq(0)) }, :foreign_key => :parent_id, :class_name => 'Gwqa::Doc'
  belongs_to :control, :foreign_key => :title_id
  belongs_to :category, :foreign_key => :category1_id

  has_many :roles, :foreign_key => :title_id, :primary_key => :title_id
  has_one :section, :foreign_key => :code, :primary_key => :section_code, :class_name => 'System::Group'

  after_create :save_name_with_check_digit
  with_options unless: :state_preparation? do |f|
    f.before_update :set_title
    f.after_save :update_answer_date
    f.after_update :update_answer_count
    f.after_destroy :update_answer_count
  end

  validates :state, presence: true
  with_options unless: :state_preparation? do |f|
    f.validates :title, presence: { message: "を入力してください。" }, if: :doc_type_question?
    f.validates :section_code, presence: { message: "記事管理課を選択してください。" }, if: :doc_type_question?
    f.validates :section_code, presence: { message: "編集可能所属を選択してください。" }, if: :doc_type_answer?
    f.validates :category1_id, presence: { message: "を設定してください。" }, if: "doc_type_question? && category_use?"
  end

  scope :public_docs, -> { where(state: 'public') }
  scope :today_public_docs, -> { where(state: 'public').latest_updated_since(Date.today) }
  scope :draft_docs, -> { where(state: 'draft') }

  scope :question_docs, -> { where(doc_type: 0) }
  scope :answer_docs, -> { where(doc_type: 1) }
  scope :public_question_docs, -> { public_docs.question_docs }

  scope :search_with_params, ->(control, params) {
    rel = all
    rel = rel.where(id: Gwqa::Doc.unscoped.select(:parent_id).search_with_text(:title, :body, params[:kwd])) if params[:kwd].present?
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
    select(:id, :title_id, :category1_id, :state, :title, :section_name, :section_code,
      :answer_count, :content_state, :latest_answer, :latest_updated_at)
  }
  scope :index_docs_with_params, ->(control, params) {
    rel = all
    case params[:state]
    when "TODAY"
      rel = rel.today_public_docs
    when "DRAFT"
      rel = rel.draft_docs
      rel = rel.group_or_creater_docs unless control.is_admin?
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
      cats = Gwqa::Category.arel_table
      order(cats[:sort_no].asc, docs[:category1_id].asc, docs[:title].asc, docs[:latest_updated_at].desc).joins(:category)
    else
      order(latest_updated_at: :desc)
    end
  }

  def doc_type_question?
    doc_type == 0
  end

  def doc_type_answer?
    doc_type == 1
  end

  def no_recog_states
    {'draft' => '下書き保存', 'recognized' => '公開待ち'}
  end

  def recog_states
    {'draft' => '下書き保存', 'recognize' => '承認待ち', 'public' => '公開保存'}
  end

  def resolved_status
    { 'unresolved' => '未解決'  , 'resolved'   =>  '解決済'}
  end

  def resolved_status_select
    [['未解決','unresolved'],['解決済','resolved']]
  end

  def qa_doc_path
    return item_home_path + 'docs'
  end

  def gwqa_doc_index_path
    return item_home_path + "docs?title_id=#{self.title_id}"
  end

  def gwqa_answer_new_path(title_id, parent_id)
    return item_home_path + "docs/new/?title_id=#{title_id}&p_id=#{parent_id}"
  end

  def gwqa_edit_path
    if self.doc_type == 0
      return item_home_path + "docs/#{self.id}/edit?title_id=#{self.title_id}&p_id=Q"
    else
      return item_home_path + "docs/#{self.id}/edit?title_id=#{self.title_id}&p_id=#{self.parent_id}"
    end
  end

  def close_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=close"
  end

  def clone_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=clone"
  end

  def publish_path
    return "/gwqa/docs/#{self.id}?title_id=#{self.title_id}&do=publish"
  end

  def item_path
    return "/gwqa/docs?title_id=#{self.title_id}"
  end

  def docs_path
    if self.doc_type == 0
      str_path = "/gwqa/docs?title_id=#{self.title_id}"
    else
      str_path = "/gwqa/docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return str_path
  end

  def show_path
    if self.doc_type == 0
      str_path = "/gwqa/docs/#{self.id}/?title_id=#{self.title_id}"
    else
      str_path = "/gwqa/docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return str_path
  end

  def edit_path
    str_path =  "/gwqa/docs/#{self.id}/edit?title_id=#{self.title_id}"
    str_path = str_path + "&parent_id=#{self.parent_id}" if self.doc_type == 1
    return str_path
  end

  def delete_path
    str_path = "/gwqa/docs/#{self.id}?title_id=#{self.title_id}"
    return str_path
  end

  def settlement_path
    str_path = ''
    str_path = "/gwqa/docs/#{self.id}/settlement?title_id=#{self.title_id}" if self.doc_type == 0
    return str_path
  end

  def update_path
    str_path = "#{Site.current_node.public_uri}#{self.id}?title_id=#{self.title_id}"
    if self.doc_type==1
      str_path = str_path + "&parent_id=#{self.parent_id}"
    else
      str_path = str_path + "&p_id=Q"
    end
    return str_path
  end

  def portal_show_path
    ret = ''
    if self.doc_type == 0
      ret = self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
    else
      ret = self.item_home_path + "docs/#{self.parent_id}/?title_id=#{self.title_id}"
    end
    return ret
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def public_answers
    answers.where(state: 'public')
  end

  def is_settlementable?(user = Core.user)
    content_state != "resolved" && (creater_id == user.code || editor_id == user.code)
  end

  private

  def save_name_with_check_digit
    update_columns(name: Util::CheckDigit.check(format('%07d', self.id))) if self.name.blank?
    update_columns(pname: Util::CheckDigit.check(format('%07d', self.parent_id))) if self.pname.blank?
  end

  def set_title
    if doc_type == 0
      answers.update_all(title: title) if title_changed?
    else
      self.title = question.title if question && question.title.present?
    end
  end

  def update_answer_count
    if state == 'public' && doc_type == 1
      question.update_columns(answer_count: question.answers.where(state: 'public').count) if question
    end
  end

  def update_answer_date
    if state == 'public' && doc_type == 1 && latest_updated_at.present?
      question.update_columns(latest_answer: latest_updated_at) if question
    end
  end
end
