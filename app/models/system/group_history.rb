require 'date'
class System::GroupHistory < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'System::GroupHistory'
  has_many :user_group, :foreign_key => :group_id, :class_name => 'System::UsersGroupHistory'
  has_many :users, -> { order(System::UsersGroupHistory.arel_table[:job_order], System::User.arel_table[:name_en]) }, :through => :user_group, :source => :user

  validates :state, :name, :start_at, presence: true
  validates :code, presence: true, uniqueness: { scope: [:parent_id, :start_at] }
  validate :validate_start_at_and_end_at

  def ou_name
    "#{code}#{name}"
  end

  def display_name
    name
  end

  def self.group_states(state)
    show_status(state)
  end

  def self.show_status(state)
    I18n.t('enum.system/group.state').stringify_keys[state]
  end

  def self.ldap_show(ldap)
    I18n.t('enum.system/group.ldap')[ldap.to_i]
  end

private

  def validate_start_at_and_end_at
    if start_at && end_at
      errors.add :end_at, 'には、適用開始日より後の日付を入力してください' if end_at.to_date <= start_at.to_date
    end
  end
end
