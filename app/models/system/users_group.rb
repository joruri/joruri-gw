class System::UsersGroup < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  self.primary_key = 'rid'

  belongs_to :user,  :foreign_key => :user_id,  :class_name => 'System::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'

  validates_presence_of :group_id, :start_at
  validates_presence_of :user_id
  validates_uniqueness_of :group_id, :scope => :user_id,
    :message => "は既に登録されています。"
  validates_uniqueness_of :job_order, :scope => :user_id, :if => lambda{|item| item.job_order == 0},
    :message => "ユーザーの本務は既に登録されています。兼務または仮配属を選択してください。"

  validates_each :end_at do |record, attr, value|
    user = System::User.where(:id =>record.user_id).first
    if value.present?
      record.errors.add attr, 'は、ユーザーの状態が「有効」の場合、空欄としてください。' if user.present? && user.state == "enabled"
      record.errors.add attr, 'には、配属開始日より後の日付を入力してください。'  if Time.local(value.year, value.month, value.day, 0, 0, 0) < Time.local(record.start_at.year, record.start_at.month, record.start_at.day, 0, 0, 0)
      record.errors.add attr, 'には、本日以前の日付を入力してください。'  if Time.local(value.year, value.month, value.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
    end
  end

  validates_each :start_at do |record, attr, value|
    if value.present?
      record.errors.add attr, 'には、本日以前の日付を入力してください。'  if Time.local(value.year, value.month, value.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
    end
  end

  before_save :set_columns, :clear_cache
  before_destroy :clear_cache
  after_save :save_users_group_history
  after_destroy :close_users_group_history

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

  def self.get_gname(uid=nil)
    uid = Core.user.id if uid.nil?
    user_group1 = System::UsersGroup.where("user_id=#{uid}").order("job_order").first
    return nil if user_group1.blank?
    group       = user_group1.group unless user_group1.blank?
    name = group.ou_name unless group.blank?
    name = nil if group.blank?
    return name
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
        when 's_keyword'
        search_keyword v, :job_order
        when 'job'
        search_id v, :job_order
      end
    end if params.size != 0

    return self
  end

private

  def clear_cache
    Rails.cache.clear
  end

  def set_columns
    if self.user_id.to_i==0
        self.user_code  = '未登録ユーザー'
    else
      if self.user.blank?
        self.user_code  = '未登録ユーザー'
      else
        self.user_code  = self.user.code
      end
    end
    if self.group_id.to_i==0
        self.group_code  = '未登録グループ'
    else
      if self.group.blank?
        self.group_code  = '未登録グループ'
      else
        self.group_code  = self.group.code
      end
    end
  end

  def save_users_group_history
    if group_id_changed?
      latest_ugh = user.user_group_histories.where(:group_id => group_id_was).order('rid DESC').first
      if latest_ugh
        latest_ugh.end_at = Core.now
        latest_ugh.save(:validate => false)
      end
      ugh = System::UsersGroupHistory.new(self.attributes.delete_if{|k,v| k == 'rid'})
      ugh.start_at = Core.now
      ugh.end_at = nil
      ugh.save(:validate => false)
    else
      latest_ugh = user.user_group_histories.where(:group_id => group_id).order('rid DESC').first
      if latest_ugh
        latest_ugh.attributes = self.attributes.delete_if{|k,v| k == 'rid'}
        latest_ugh.save(:validate => false)
      end
    end
  end

  def close_users_group_history
    latest_ugh = user.user_group_histories.where(:group_id => group_id).order('rid DESC').first
    if latest_ugh
      latest_ugh.end_at = Core.now
      latest_ugh.save(:validate => false)
    end
  end
end
