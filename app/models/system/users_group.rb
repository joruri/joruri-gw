class System::UsersGroup < ActiveRecord::Base
  self.primary_key = 'rid'
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree

  attr_accessor :skip_user_id_validation

  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'

  before_save :set_user_code
  before_save :set_group_code
  after_save :save_users_group_history
  after_destroy :close_users_group_history
  after_commit :clear_cache

  validates :user_id, presence: true, unless: :skip_user_id_validation
  validates :group_id, presence: true, uniqueness: { scope: :user_id, message: "は既に登録されています。" }
  validates :start_at, presence: true
  validates :job_order, uniqueness: { scope: :user_id, message: "ユーザーの本務は既に登録されています。兼務または仮配属を選択してください。" }, 
    if: :job_order_regular?
  validate :validate_start_at
  validate :validate_end_at
  validate :validate_start_at_and_end_at

  def job_order_regular?
    job_order == 0
  end

  def job_order_additional?
    job_order == 1
  end

  def job_order_temporary?
    job_order == 9
  end

  def self.job_order_options
    [['本務',0],['兼務',1],['仮所属',9]]
  end

  def self.job_order_show(job_order)
    job_order_options.rassoc(job_order.to_i).try(:first)
  end

  def self.ldap_options
    [['非同期',0],['同期',1]]
  end

  def self.ldap_show(ldap)
    ldap_options.rassoc(ldap.to_i).try(:first)
  end

  def self.state_options
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    state_options.rassoc(state).try(:first)
  end

  def show_group_name(error = Gw.user_groups_error)
    group.try(:ou_name) || error
  end

  def latest_users_group_history
    user.user_group_histories.where(group_id: group_id).order(rid: :desc).limit(1)
  end

private

  def validate_start_at
    if start_at
      errors.add :start_at, 'には、本日以前の日付を入力してください。' if start_at.to_date > Date.today
    end
  end

  def validate_end_at
    if end_at
      errors.add :end_at, 'は、ユーザーの状態が「有効」の場合、空欄としてください。' if user && user.state == "enabled"
      errors.add :end_at, 'には、本日以前の日付を入力してください。' if end_at.to_date > Date.today
    end
  end

  def validate_start_at_and_end_at
    if start_at && end_at
      errors.add :end_at , 'には、配属開始日より後の日付を入力してください。' if end_at.to_date < start_at.to_date
    end
  end

  def clear_cache
    Rails.cache.clear
  end

  def set_user_code
    if user_id_changed?
      if user
        self.user_code = user.code
      else
        self.user_code = '未登録ユーザー'
      end
    end
  end

  def set_group_code
    if group_id_changed?
      if group
        self.group_code = group.code
      else
        self.group_code = '未登録グループ'
      end
    end
  end

  def save_users_group_history
    if group_id_changed?
      save_users_group_history_on_group_changed
    else
      save_users_group_history_on_group_unchanged
    end
  end

  def save_users_group_history_on_group_changed
    user.user_group_histories.where(group_id: group_id_was).order(rid: :desc).limit(1).update_all(
      end_at: Core.now,
      updated_at: Time.now
    )
    ugh = System::UsersGroupHistory.new(self.attributes.except('rid'))
    ugh.start_at = Core.now
    ugh.end_at = nil
    ugh.save(validate: false)
  end

  def save_users_group_history_on_group_unchanged
    latest_users_group_history.update_all(
      self.attributes.except('rid').merge(updated_at: Time.now)
    )
  end

  def close_users_group_history
    latest_users_group_history.update_all(
      end_at: Core.now,
      updated_at: Time.now
    )
  end
end
