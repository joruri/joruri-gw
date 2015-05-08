require 'date'
class System::Group < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  extend ActsAsTree::TreeWalker

  acts_as_tree order: { sort_no: :asc, code: :asc }, dependent: :destroy

  has_many :enabled_children, -> { where(state: 'enabled').order(sort_no: :asc, code: :asc) }, :foreign_key => :parent_id, :class_name => 'System::Group'
  has_many :user_group, :foreign_key => :group_id, :class_name => 'System::UsersGroup'
  has_many :users, -> { order(System::UsersGroup.arel_table[:job_order], System::User.arel_table[:name_en]) }, :through => :user_group, :source => :user

  after_save :save_group_history
  after_commit :clear_cache

  validates :state, :name, :start_at, presence: true
  validates :code, presence: true, uniqueness: { scope: [:parent_id] }, 
    format: { with: /\A[0-9A-Za-z\_]+\z/, message: "は、半角英数字および半角アンダーバーのみ使用可能です。" }
  validates :sort_no, numericality: true
  validate :validate_state
  validate :validate_start_at
  validate :validate_end_at
  validate :validate_start_at_and_end_at

  def ou_name
    "#{code}#{name}"
  end

  def display_name
    name
  end

  def tree_name
    if level_no >= 2
      "　　"*(level_no-2) + "(#{code})#{name}"
    else
      "(#{code})#{name}"
    end
  end

  def self.state_options
    [['有効','enabled'],['無効','disabled']]
  end

  def self.ldap_options
    [['非同期',0],['同期',1]]
  end

  def self.ldap_show(ldap)
    ldap_options.rassoc(ldap.to_i).try(:first)
  end

  def self.level_show(level_no)
    case level_no
    when 1; "root"
    when 2; "部局"
    else "所属"
    end
  end

  def self.get_level2_groups
    System::Group.where(:level_no => 2).order(:code, :sort_no, :id)
  end

  def csvget_data
    [
      System::UsersGroup.state_show(state),
      "group",
      System::Group.level_show(level_no),
      parent.try(:code),
      code,
      System::UsersGroup.ldap_show(ldap),
      "",
      name,
      name_en,
      "",
      "",
      "",
      "",
      email,
      "",
      "",
      Gw.date_str(start_at),
      Gw.date_str(end_at)
    ]
  end

  def self_and_descendants(arr = [])
    arr << self
    children.each {|g| g.self_and_descendants(arr) }
    arr
  end

  def self_and_enabled_children
    [self] + enabled_children
  end

  def enabled_descendants(arr = [])
    enabled_children.each {|g| arr << g; g.enabled_descendants(arr) }
    arr
  end

  def self_and_enabled_descendants(arr = [])
    arr << self
    enabled_children.each {|g| g.self_and_enabled_descendants(arr) }
    arr
  end

  def enabled_users_for_options(options = {})
    us = users.select(:id, :code, :name).where(state: 'enabled')
      .where.not(id: Gw::PropTypesUser.select(:user_id))
      .reorder(:code)
    us = us.where(ldap: 1) if options[:ldap] == 1 && Joruri.config.application['system.show_only_ldap_user']
    us
  end

  def enabled_user_options(options = {})
    enabled_users_for_options(options).map {|u| [Gw.trim(u.display_name), u.id] }
  end

  def enabled_group_options(options = {})
    enabled_descendants.map{|g| ["　　"*(g.level_no-self.level_no-1) + "(#{g.code})#{g.name}", g.id]}
  end

  def disableable?
    users.size == 0 && enabled_descendants.size == 0
  end

  class << self
    def enabled_groups_for_options
      self.select(:id, :code, :name, :level_no)
        .where(state: 'enabled').where.not(level_no: 1)
        .order(sort_no: :asc, code: :asc, name: :asc)
    end

    def enabled_group_options
      enabled_groups_for_options.map{|g| [g.tree_name, g.id]}
    end

    def enabled_group_options_without_leaf
      max_level = self.maximum(:level_no)
      self.select(:id, :code, :name, :level_no)
        .where(state: 'enabled').where.not(level_no: [1, max_level])
        .order(:sort_no, :code, :name).map{|g| [g.tree_name, g.id]}
    end
  end

private

  def validate_state
    if state.present?
      errors.add :state, 'は、上位所属が「無効」のため、「有効」に変更できません。' if parent && parent.state == "disabled" && state == "enabled"
    end
  end

  def validate_start_at
    if start_at
      errors.add :start_at, 'には、本日以前の日付を入力してください。' if start_at.to_date > Date.today
    end
  end

  def validate_end_at
    if end_at
      errors.add :end_at, 'は、状態が「有効」の場合、空欄としてください。' if state == "enabled"
      errors.add :end_at, 'には、本日以前の日付を入力してください。' if end_at.to_date > Date.today
    end
  end

  def validate_start_at_and_end_at
    if start_at && end_at
      errors.add :end_at, 'には、適用開始日より後の日付を入力してください。' if end_at.to_date < start_at.to_date
    end
  end

  def clear_cache
    Rails.cache.clear
  end

  def save_group_history
    group_history = System::GroupHistory.where(id: self.id).first
    if group_history.blank?
      group_history = System::GroupHistory.new
      group_history.id = self.id
    end
    group_history.attributes = self.attributes.except('id')
    group_history.save
  end
end
