require 'digest/sha1'
class System::User < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  has_many :group_rels, :foreign_key => :user_id, :class_name => 'System::UsersGroup', :primary_key => :id
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

  attr_accessor :in_password, :in_group_id, :encrypted_password

  validates_presence_of :code, :name, :state, :ldap
  validates_uniqueness_of :code

  before_save :encrypt_password
  after_save :save_users_group

  scope :with_enabled, -> { where(state: 'enabled') }

  def name_with_id
    "#{name}（#{id}）"
  end

  def name_and_code
    name + '(' + code + ')'
  end

  def name_with_account
    "#{name}（#{code}）"
  end

  def display_name
    return "#{name} (#{code})"
  end

  def label(name)
    case name; when nil; end
  end

  def group_name
    user_groups.get_gname(id)
  end

  def groups_and_ancestors
    return @groups_and_ancestors if @groups_and_ancestors
    @groups_and_ancestors = (groups + groups.map(&:ancestors).flatten).uniq
  end

  def show_group_name(error = Gw.user_groups_error)
    group = self.groups.collect{|x| ("#{x.code}") + %Q(#{x.name})}.join(' ')
    if group.blank?
      return error
    else
      return group
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

  def self.m_access_select
    [['不許可（標準）',0],['許可',1]]
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

  def delete_group_relations
    System::UsersGroup.delete_all(:user_id => id)
    return true
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :code , :name , :name_en , :email
      end
    end if params.size != 0

    return self
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
    roles = System::Role.arel_table
    System::Role.where(table_name: table, priv_name: priv).where([
        roles[:class_id].eq(0),
        roles[:class_id].eq(1).and( roles[:uid].eq(id) ),
        roles[:class_id].eq(2).and( roles[:uid].in(groups[0].self_and_ancestors.map(&:id)) )
      ].reduce(:or)
    ).order(:idx).first.try(:priv) == 1
  end
  memoize :has_table_priv?

  def has_auth?(name)
    auth = {
      :none     => 0,
      :reader   => 1,
      :creator  => 2,
      :editor   => 3,
      :designer => 4,
      :manager  => 5,
      }

    return 5
  end

  def has_priv?(action, options = {})
    return true
    return true if has_auth?(:manager)
    return nil unless options[:item]

    item = options[:item]
    if item.kind_of?(ActiveRecord::Base)
      item = item.unid
    end

    cond  = "user_id = :user_id"
    cond += " AND role_id IN (" +
      " SELECT role_id FROM system_object_privileges" +
      " WHERE action = :action AND item_unid = :item_unid )"
    params = {
      :user_id   => id,
      :action    => action.to_s,
      :item_unid => item,
    }
    System::UsersRole.where(cond, params).first
  end

  def self.logger
    @@logger ||= RAILS_DEFAULT_LOGGER
  end

  ## Authenticates a user by their account name and unencrypted password.  Returns the user or nil.
  def self.authenticate(in_account, in_password, encrypted = false)
    in_password = Util::String::Crypt.decrypt(in_password) if encrypted

    user = nil
    self.where(code: in_account, state: 'enabled').all.each do |u|
      if u.ldap == 1
        ## LDAP Auth
        next unless ou1 = u.groups[0]
        next unless ou2 = ou1.parent
        dn = "uid=#{u.code},ou=#{ou1.ou_name},ou=#{ou2.ou_name},#{Core.ldap.base}"

        if Core.ldap.connection.bound?
          Core.ldap.connection.unbind
          Core.ldap = nil
        end
        next unless Core.ldap.bind(dn, in_password)
        u.password = in_password
      else
        ## DB Auth
        next if in_password != u.password || u.password.to_s == ''
      end
      user = u
      break
    end
    return user
  end

  def self.encrypt(in_password, salt)
    in_password
  end

  def encrypt(in_password)
    in_password
  end

  def encrypt_password
    return if password.blank?
    Util::String::Crypt.encrypt(password)
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

  def previous_login_date
    return @previous_login_date if @previous_login_date
    if (list = logins.order(:created_at).limit(2)).size != 2
      return nil
    end
    @previous_login_date = list[1].login_at
  end

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

  def save_with_rels(options)
    # only user create
    # create users_groups / users_group_histsorires after user create
    params = options[:params]
    ret = []
    ret[0]  = true
    ret[1]  = ""

    if System::User.valid_user_code_characters?(self.code) == false
      ret[1]="ユーザーIDは半角英数字、および半角アンダーバーのみのデータとしてください。"
      ret[0]=false
      return ret
    end


    # validate of params
    valid = true

    if params[:ug]['group_id'].to_i==0
      valid = false
    end

    if params[:ug]['start_at'].blank?
      valid = false
    else
      start_dt  = params[:ug]['start_at'].split('-')
      if start_dt.size == 3
        st_at = Time.local(start_dt[0],start_dt[1],start_dt[2] , 0 , 0 , 0 )
      else
        valid = false
      end
    end

    if params[:ug]['end_at'].blank?
      ed_at = nil
      valid = true
    else
      end_dt  = params[:ug]['end_at'].split('-')
      if end_dt.size==3
        ed_at = Time.local(end_dt[0],end_dt[1],end_dt[2] , 0 , 0 , 0 )
      else
        valid = false
      end
    end

    if valid==false
      ret[1]="所属の指定・配属の日付けにエラーがあります。"
      ret[0]=false
      return ret
    end

    # save user
    if self.save

      if params[:ug]
          ugr = System::UsersGroup.new
          ugr.user_id   = self.id
          ugr.group_id  = params[:ug]['group_id'].to_i
          ugr.job_order = params[:ug]['job_order'].to_i
          ugr.start_at  = st_at
          ugr.end_at    = ed_at
        if ugr.save
          ugh = System::UsersGroupHistory.new
          ugh.user_id   = self.id
          ugh.group_id  = params[:ug]['group_id'].to_i
          ugh.job_order = params[:ug]['job_order'].to_i
          ugh.start_at  = st_at
          ugh.end_at    = ed_at
          #ugh.save(:validate=>false)
          if ugh.save
          else
            ret[1] = '登録ユーザーのグループ割当に失敗しました。'
            ret[0]=false
            return ret
          end
        else
          ret[1] = '登録ユーザーのグループ割当に失敗しました。'
          ret[0]=false
          return ret
        end
      else
          ret[1] = '登録ユーザーのグループ割当に失敗しました。'
          ret[0]=false
          return ret
      end
      ret[1]=""
      ret[0]=true
      return ret
    else
      ret[1]="登録に失敗しました。"
      ret[0]=false
      return ret
    end
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
