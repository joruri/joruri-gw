require 'digest/sha1'
class System::User < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  attr_accessor :in_password, :in_group_id, :encrypted_password

  has_many :user_groups, :foreign_key => :user_id, :class_name => 'System::UsersGroup'
  has_many :groups, -> { order(System::UsersGroup.arel_table[:job_order], System::Group.arel_table[:sort_no]) }, :through => :user_groups, :source => :group
  has_many :user_group_histories, :foreign_key => :user_id,:class_name => 'System::UsersGroupHistory'
  has_many :users_custom_groups, :foreign_key => :user_id, :dependent => :destroy
  has_many :logins, -> { order(:id => :desc) }, :foreign_key => :user_id, :class_name => 'System::LoginLog', :dependent => :delete_all

  has_one :todo_property, :foreign_key => :uid, :class_name => 'Gw::Property::TodoSetting'
  has_one :memo_mobile_property, :foreign_key => :uid, :class_name => 'Gw::Property::MemoMobileMail'
  has_one :memo_reminder_property, :foreign_key => :uid, :class_name => 'Gw::Property::MemoReminder'

  accepts_nested_attributes_for :user_groups, :allow_destroy => true,
    :reject_if => proc{|attrs| attrs['group_id'].blank?}

  before_save :encrypt_password
  after_save :save_users_group

  validates :name, :state, :ldap, presence: true
  validates :code, presence: true, uniqueness: true, 
    format: { with: /\A[0-9A-Za-z\-\_]+\z/, message: "は半角英数字および半角アンダーバーのみ使用可能です。" }

  scope :with_enabled, -> { where(state: 'enabled') }

  def name_with_id
    "#{name}（#{id}）"
  end

  def name_and_code
    "#{name}(#{code})"
  end

  def name_with_account
    "#{name}（#{code}）"
  end

  def display_name
    "#{name} (#{code})"
  end

  def group_name
    groups.first.try(:ou_name)
  end

  def show_group_name(none = Gw.user_groups_error)
    if groups.present?
      groups.map(&:ou_name).join(', ')
    else
      none
    end
  end

  def mobile_pass_check
    valid = true
    if self.mobile_password.size < 4
        self.errors.add :mobile_password, 'は４文字以上で入力してください。'
        valid = false
    end
    return valid
  end

  def self.state_options
    [['有効','enabled'],['無効','disabled']]
  end

  def self.ldap_options
    [['非同期',0],['同期',1]]
  end

  def mobile_access_label
    self.class.m_access_select.rassoc(mobile_access).try(:first)
  end

  def self.m_access_select
    [['不可（標準）',0],['許可',1]]
  end

  def self.m_access_show(access)
    m_access_select.rassoc(access.to_i).try(:first)
  end

  def self.mobile_access_csv_show
    [['許可',1],['不可',0]]
  end

  def self.mobile_access_show(mobile)
    mobile_access_csv_show.rassoc(nz(mobile, 0)).try(:first)
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('_admin/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def self.is_editor?(user = Core.user)
    user.has_role?('system_users/editor')
  end

  def self.get_user_select(g_id = nil, all = nil, options = {})
    selects = []
    selects << ['すべて', 0] if all == 'all'
    selects += if g_id.blank?
        Core.user_group.enabled_user_options(options)
      else
        group = System::Group.find_by(id: g_id)
        group ? group.enabled_user_options(options) : []
      end
  end

  def self.get(uid=nil)
    uid = Core.user.id if uid.nil?
    self.where("id=#{uid}").first
  end

  def has_role?(*table_privs)
    table_privs.each do |table_priv|
      table, priv = table_priv.split('/')
      next if table.blank? || priv.blank?

      return true if has_table_priv?(table, priv)
    end
    return false
  end

  def has_table_priv?(table, priv)
    role = System::Role.where(table_name: table, priv_name: priv).roles_for_user(self).order(idx: :asc).first
    role.try(:priv) == 1
  end
  memoize :has_table_priv?

  #ユーザID（user code)で有効な文字か？
  def self.valid_user_code_characters?(string)
    return self.half_width_characters?(string)
  end

  def self.half_width_characters?(string)
    # 半角英数字、および半角アンダーバーのチェック
    if string =~  /^[0-9A-Za-z\_]+$/
      return true
    else
      false
    end
  end

  def first_group_code
    groups.first.try(:code)
  end

  def first_group_and_ancestors_ids
    if groups.first
      groups.first.self_and_ancestors.map(&:id)
    else
      []
    end
  end

  def groups_and_ancestors_codes
    groups.map(&:self_and_ancestors).flatten.compact.map(&:code).uniq
  end

  def previous_login_date
    return @previous_login_date if @previous_login_date
    if (list = logins.order(:created_at).limit(2)).size != 2
      return nil
    end
    @previous_login_date = list[1].login_at
  end

  ## Authenticates a user by their account name and unencrypted password.  Returns the user or nil.
  def self.authenticate(in_account, in_password, encrypted = false)
    in_password = Util::Crypt.decrypt(in_password) if encrypted

    self.where(code: in_account, state: 'enabled').all.each do |u|
      if u.ldap == 1
        if Core.ldap.connection.bound?
          Core.ldap.connection.unbind
          Core.ldap = nil
        end
        if Core.ldap.bind(u.bind_dn, in_password)
          u.password = in_password
          return u
        end
      else
        if u.password.present? && u.password == in_password
          return u
        end
      end
    end
    return nil
  end

  def bind_dn
    group_path = groups.first.self_and_ancestors.reject(&:root?)
    ous = group_path.map{|g| "ou=#{g.ou_name}"}.join(',')

    Core.ldap.bind_dn
      .gsub("[base]", Core.ldap.base.to_s)
      .gsub("[domain]", Core.ldap.domain.to_s)
      .gsub("[uid]", code.to_s)
      .gsub("[ous]", ous.to_s)
  end

  def self.encrypt(in_password, salt)
    in_password
  end

  def encrypt(in_password)
    in_password
  end

  def encrypt_password
    return if password.blank?
    Util::Crypt.encrypt(password)
  end

  def authenticated?(in_password)
    password == encrypt(in_password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    #save(:validate => false)
    update_attributes :remember_token_expires_at => nil, :remember_token => nil
  end

protected

  def password_required?
    password.blank? || !in_password.blank?
  end

  def save_users_group
    return if in_group_id.blank?

    if ug = user_groups.find{|item| item.job_order == 0}
      if in_group_id != ug.group_id
        ug.group_id = in_group_id
        ug.start_at = Core.now
        ug.end_at = nil
        ug.save(:validate => false)
      end
    else
      System::UsersGroup.create(
        :user_id   => id,
        :group_id  => in_group_id,
        :start_at  => Core.now,
        :job_order => 0
      )
    end
  end
end
