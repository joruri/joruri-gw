class Gwworkflow::Doc < Gw::Database
  self.table_name = 'gw_workflow_docs'
  include System::Model::Base
  include System::Model::Base::Content
  include Gwworkflow::Model::Systemname
  include Concerns::Gwworkflow::Doc::Query
  include Concerns::Gwworkflow::Doc::Step

  has_many :files, foreign_key: :parent_id, class_name: 'Gwworkflow::File', dependent: :destroy
  has_many :steps, ->{ order(number: :asc) }, foreign_key: :doc_id, class_name: 'Gwworkflow::Step', dependent: :destroy

  accepts_nested_attributes_for :steps, allow_destroy: true

  after_save :update_state, on: :update
  after_save :update_current_number, on: :update

  validates :title, presence: true, length: { maximum: 140 }
  validates :expired_at, presence: true
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

  def real_state
    state.to_sym
  end

  def current_step
    steps.detect {|step| step.number == current_number }
  end

  def future_steps
    steps.select{|step| step.number > current_number }
  end

  def unmarked_steps
    steps.reject(&:marked_for_destruction?)
  end

  def expired?
    expired_at && expired_at < Time.now
  end

  def unfinished?
    !real_state.in?([:accepted, :rejected, :remanded])
  end

  def showable?(user = Core.user)
    creater_id == user.id || steps.any? {|step| step.committee.user_id == user.id }
  end

  def elaboratable?(user = Core.user)
    creater_id == user.id && real_state.in?([:quantum, :draft])
  end

  def reapplyable?(user = Core.user)
    creater_id == user.id && real_state == :remanded
  end

  def approvable?(user = Core.user)
    current_step && current_step.committees.any? {|c| c.user_id == user.id }
  end

  def pullbackable?(user = Core.user)
    creater_id == user.id && real_state == :applying
  end

  def destroyable?(user = Core.user)
    creater_id == user.id && real_state != :applying
  end

  def pullback
    self.state = 'draft'
    self.current_number = -1
    steps.each do |step|
      step.updated_at = Time.now
      step.committees.each do |committee|
        committee.state = 'undecided'
      end
    end
    self.save(validate: false)
  end

  private

  def committees_valid
    if unmarked_steps.length == 0
      errors.add('承認ステップ', 'を少なくとも1つ設定してください。')
    end
  end

  def _real_state
    if state.to_sym == :applying
      return :accepted if steps.all?{|step| step.state == :accepted }
      return :rejected if steps.any?{|step| step.state == :rejected }
      return :remanded if steps.any?{|step| step.state == :remanded }
    end
    return state.to_sym
  end

  def update_state
    new_state = _real_state
    update_columns(state: new_state) if state != new_state
  end

  def update_current_number
    case real_state
    when :quantum, :draft
      update_columns(current_number: -1)
    when :applying
      if next_step = steps.detect {|step| step.state == :undecided }
        update_columns(current_number: next_step.number) if current_number != next_step.number
      end
    when :accepted
      update_columns(current_number: steps.size)
    end
  end
end
