class System::UsersGroupHistory < ActiveRecord::Base
  self.primary_key = 'rid'
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::GroupHistory'

  before_save :set_user_code
  before_save :set_group_code

  validates :group_id, :user_id, :start_at, presence: true
  validate :validate_start_at_and_end_at

  def self.select_state
    I18n.a('enum.system/users_group.job_order')
  end

  def self.ldap_show(ldap)
    I18n.t('enum.system/user.ldap')[ldap.to_i]
  end

private

  def validate_start_at_and_end_at
    if start_at && end_at
      errors.add :end_at , 'には適用開始日以降の日付を入力してください' if end_at.to_date < start_at.to_date
    end
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
end
