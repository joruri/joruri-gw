class Gwworkflow::Doc < Gw::Database
  self.table_name = 'gw_workflow_docs'
  include System::Model::Base
  include System::Model::Base::Content
  include Gwworkflow::Model::Systemname

  has_many :files, foreign_key: :parent_id, class_name: 'Gwworkflow::File', dependent: :destroy
  has_many :steps, ->{ order(number: :asc) }, foreign_key: :doc_id, class_name: 'Gwworkflow::Step', dependent: :destroy

  accepts_nested_attributes_for :steps, allow_destroy: true

  after_validation :delete_route
  after_save :update_state, on: :update
  after_save :update_current_number, on: :update

  validates :title, presence: true, length: { maximum: 140 }
  validates :expired_at, presence: true
  validate :date_valid
  validate :committees_valid

  scope :with_draft_docs, -> { where(state: 'draft') }
  scope :with_applying_docs, -> { where(state: 'applying') }
  scope :with_accepted_docs, -> { where(state: 'accepted') }
  scope :with_rejected_docs, -> { where(state: 'rejected') }
  scope :with_remanded_docs, -> { where(state: 'remanded') }
  scope :without_preparation, -> { where.not(state: 'quantum') }

  scope :updated_after, ->(time = Time.now) {
    where(arel_table[:updated_at].gteq(time))
  }

  scope :owner_docs, ->(user = Core.user) {
    where(creater_id: user.id)
  }
  scope :user_processing_docs, ->(user = Core.user) {
    committees = Gwworkflow::Committee.with_committee(user).with_undecided
    joins(:steps => :committees)
      .where.not(state: 'draft')
      .where(arel_table[:current_number].eq(Gwworkflow::Step.arel_table[:number]))
      .merge(committees)
  }
  scope :user_processed_docs, ->(user = Core.user) {
    committees = Gwworkflow::Committee.with_committee(user).with_processed
    joins(:steps => :committees)
      .where.not(state: 'draft')
      .merge(committees)
  }
  scope :search_with_params, ->(params) {
    rel = all.distinct.without_preparation

    case params[:cond]
    when 'processing'
      rel = rel.user_processing_docs(Core.user)
    when 'processed'
      rel = rel.user_processed_docs(Core.user)
    else
      rel = rel.owner_docs(Core.user)
    end

    case params[:filter]
    when 'draft'
      rel = rel.with_draft_docs
    when 'applying'
      rel = rel.with_applying_docs
    when 'accepted'
      rel = rel.with_accepted_docs
    when 'rejected'
      rel = rel.with_rejected_docs
    when 'remanded'
      rel = rel.with_remanded_docs
    end
    rel
  }
  scope :index_order_with_params, ->(params) {
    rel = all
    if params[:sort].in?(%w(applied_at expired_at updated_at)) && params[:order].in?(%w(asc desc))
      rel = rel.order(params[:sort].to_sym => params[:order].to_sym)
    end
    rel = rel.order(id: :desc)
  }

  def real_state
    state.to_sym
  end

  def _real_state
    if state.to_sym == :applying
      return :accepted if steps.all?{|step| step.state == :accepted }
      return :rejected if steps.any?{|step| step.state == :rejected }
      return :remanded if steps.any?{|step| step.state == :remanded }
    end
    return state.to_sym
  end

  def total_steps
    steps.length
  end

  def now_step
    s = current_step
    s ? s.number : total_steps
  end

  def current_step
    steps.detect{|step| step.state.to_sym != :accepted }
  end

  def fixed_steps
    steps.select{|step| step.accepted? }
  end

  def future_steps
    steps.select{|step| step.number > current_number }
  end

  def future_committees
    future_steps.map{|step| step.committee }
  end

  def expired?
    expired_at && expired_at < Time.now
  end

  def unfinished?
    !real_state.in?([:accepted, :rejected, :remanded])
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def showable?(user = Core.user)
    creater_id == user.id || steps.any? {|step| step.committee.user_id == user.id }
  end

  def elaboratable?(user = Core.user)
    creater_id == user.id && real_state == :draft
  end

  def reapplyable?(user = Core.user)
    creater_id == user.id && real_state == :remanded
  end

  def approvable?(user = Core.user)
    state.to_sym != :draft && current_step && current_step.committees.any? {|c| c.user_id == user.id }
  end

  def pullbackable?(user = Core.user)
    creater_id == user.id && real_state == :applying
  end

  def destroyable?(user = Core.user)
    creater_id == user.id && real_state != :applying
  end

  def pullback
    transaction do
      self.state = 'draft'
      self.current_number = 0
      self.save(validate: false)
      steps.each do |step|
        step.updated_at = Time.now
        step.committees.each do |committee|
          committee.state = 'undecided'
          committee.comment = ''
          committee.decided_at = nil
          committee.save(validate: false)
        end
      end
    end
  end

  private

  def date_valid
    # errors.add('期限日', 'は現在よりも後に設定してください。') if expired_at <= DateTime.now
  end

  def committees_valid
    errors.add('承認ステップ', 'を少なくとも1つ設定してください。') if steps.length == 0
  end

  def delete_route
    if errors.size > 0
      steps.each{|s|s.destroy}
    end
  end

  def update_state
    new_state = _real_state
    update_columns(state: new_state) if state != new_state
  end

  def update_current_number
    if current_step
      new_number = current_step.number
      update_columns(current_number: new_number) if current_number != new_number
    end
  end
end
