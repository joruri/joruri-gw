class System::CustomGroup < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::System::CustomGroup::Role

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'System::CustomGroup'
  has_many :children, :foreign_key => :parent_id, :class_name => 'System::CustomGroup'

  has_many :user_custom_group, :foreign_key => :custom_group_id, :class_name => 'System::UsersCustomGroup', :dependent => :destroy
  has_many :custom_group_role, :foreign_key => :custom_group_id, :class_name => 'System::CustomGroupRole', :dependent => :destroy
  belongs_to :owner_group, :foreign_key => :owner_gid, :class_name => 'System::Group'
  belongs_to :owner, :foreign_key => :owner_uid, :class_name => 'System::User'
  belongs_to :updater_group, :foreign_key => :updater_gid, :class_name => 'System::Group'
  belongs_to :updater, :foreign_key => :updater_uid, :class_name => 'System::User'

  accepts_nested_attributes_for :user_custom_group, allow_destroy: true
  accepts_nested_attributes_for :custom_group_role, allow_destroy: true

  before_create :set_values
  before_create :set_owner
  before_update :set_updater

  validates :state, :name, presence: true
  validate :validate_custom_group_limit, on: :create

  scope :with_owner_or_admin_role, ->(user = Core.user) {
    eager_load(:custom_group_role).where([
      arel_table[:owner_uid].eq(user.id), 
      System::CustomGroupRole.with_user_or_group(user, 'admin').where_values.reduce(:and)
    ].reduce(:or))
  }

  def state_label
    self.class.states.rassoc(state).try(:first)
  end

  def self.states
    [['無効', 'disabled'], ['有効', 'enabled']]
  end

  def kind_show
    sort_prefix.blank? ? "共有" : "個人"
  end

  def self.get_my_view(options={})
    items = self.distinct.select(:id, :parent_id, :owner_uid, :owner_gid, :state, :name, :name_en, :sort_no, :sort_prefix, :is_default)
      .joins(:custom_group_role)
      .where(state: 'enabled')
      .merge(System::CustomGroupRole.with_user_or_group(Core.user, options[:priv] == :edit ? 'edit' : 'read'))

    if options[:is_default] == 1
      items = items.where(is_default: 1, name: Core.user_group.name)
    end
    if options[:sort_prefix].present?
      items = items.where(sort_prefix: options[:sort_prefix])
    end

    if options[:first] == 1
      items.first
    else
      items
    end
  end

  def self.get_user_select(options={})
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    glist = System::CustomGroup.get_my_view( { :priv => :edit, :is_default => 1 } )
    glist.each {|x|
      x.user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.each{|x|
        selects.push [Gw.trim( x.user.display_name ),  x.user.id]
      }
    }
    return selects
  end

  def self.schedule_get_user_select(options={})
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    items = self.get_my_view(priv: :edit, is_default: 1).preload(:user_custom_group => :user)
    items.each do |item|
      item.user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.each do |ucg|
        if ucg.user && ucg.user.state == 'enabled'
          selects << [ucg.user.display_name, ucg.user.id]
        end
      end
    end
    selects
  end

  def self.create_new_custom_group(custom_group, group, customGroup_sort_no, mode)
    custom_group.name        = group.name
    custom_group.state       = 'enabled'
    custom_group.sort_no     = customGroup_sort_no
    custom_group.sort_prefix = ''
    custom_group.is_default  = 1
    custom_group.updater_uid = Core.user.id
    custom_group.updater_gid = Core.user_group.id
    custom_group.name_en     = 'sectionSchedules'
    custom_group.save(:validate => false)

    custom_group_id = custom_group.id

    if mode == :update
      custom_group.user_custom_group.each do |custom_user|
        custom_user.destroy
      end
      custom_group.custom_group_role.each do |custom_role|
        custom_role.destroy
      end
    end

    custom_group_admin = System::CustomGroupRole.new
    custom_group_admin.group_id         = group.id
    custom_group_admin.custom_group_id  = custom_group_id
    custom_group_admin.priv_name        = 'admin'
    custom_group_admin.class_id         = 2
    custom_group_admin.save(:validate => false)

    if !group.parent_id.blank? && !group.parent.blank?
      group.parent.children.each do |child|
        custom_group_edit = System::CustomGroupRole.new
        custom_group_edit.group_id         = child.id
        custom_group_edit.custom_group_id  = custom_group_id
        custom_group_edit.priv_name        = 'edit'
        custom_group_edit.class_id         = 2
        custom_group_edit.save(:validate => false)

        custom_group_read = System::CustomGroupRole.new
        custom_group_read.group_id         = child.id
        custom_group_read.custom_group_id  = custom_group_id
        custom_group_read.priv_name        = 'read'
        custom_group_read.class_id         = 2
        custom_group_read.save(:validate => false)
      end
    end

    custom_group_users = Array.new

    bu_user = nil
    if group.parent_id > 0
      parent_group = System::Group.where(:id =>group.parent_id).first
      unless parent_group.blank?
        bu_user_code = parent_group.code.to_s
        bu_user_code = bu_user_code.to_s + "_0"
        bu_user = System::User.where("code = '#{bu_user_code}' and state = 'enabled'").first
      end
    end
    custom_group_users << bu_user unless bu_user.blank?

    ka_user_code = group.code.to_s + "_0"
    ka_user = System::User.where("code = '#{ka_user_code}' and state = 'enabled'").first
    custom_group_users << ka_user unless ka_user.blank?

    user_ids = Array.new
    _ka_user_code = "#{group.code}0"
    group.user_group.each do |user_group|
      user_ids << user_group.user_id if !user_group.blank? && user_group.user_code != _ka_user_code
    end

    users = Array.new
    unless user_ids.empty?
      user_ids_str = Gw.join(user_ids, ',')
      users = System::User.where("id in (#{user_ids_str}) and state = 'enabled'").order('sort_no, code')
    end

    users.each do |user|
      custom_group_users << user
    end

    custom_group_users.each_with_index do |custom_user, i|
      unless custom_user.blank?
        users_custom_group = System::UsersCustomGroup.new
        users_custom_group.user_id          = custom_user.id
        users_custom_group.sort_no          = i * 5
        users_custom_group.custom_group_id  = custom_group_id

        case custom_user.code
        when /^\w{3}_0/

          users_custom_group.title_en          = 'department'
          users_custom_group.icon             = 8
        when /^\w{6}_0/

          users_custom_group.title_en          = 'section'
          users_custom_group.icon             = 7
        else
          users_custom_group.title            = custom_user.official_position
          users_custom_group.icon             = 1
        end
        users_custom_group.save(:validate => false)
      end
    end
    return true
  end

  private

  def set_values
    self.class_id ||= 1
    self.is_default ||= 0
    self.sort_prefix ||= Gw.is_admin_admin? ? '' : Core.user.code
  end

  def set_owner
    self.owner_uid = Core.user.id if Core.user
    self.owner_gid = Core.user_group.id if Core.user_group
    self.updater_uid = Core.user.id if Core.user
    self.updater_gid = Core.user_group.id if Core.user_group
  end

  def set_updater
    self.updater_uid = Core.user.id if Core.user
    self.updater_gid = Core.user_group.id if Core.user_group
  end

  def validate_custom_group_limit
    return if Gw.is_admin_admin?

    if System::CustomGroup.where(owner_uid: Core.user.id).count >= 5
      errors.add(:base, "カスタムグループは5件までしか作成できません。")
    end
  end
end
