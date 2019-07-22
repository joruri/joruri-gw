class Gw::PrefDirector < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  attr_accessor :_destroy_flag

  has_many :group_directors, -> { order(:u_order) }, :foreign_key => :parent_g_order, :primary_key => :parent_g_order, :class_name => self.name
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :gid, :class_name => 'System::Group'
  belongs_to :parent_group, :foreign_key => :parent_gid, :class_name => 'System::Group'

  accepts_nested_attributes_for :group_directors, allow_destroy: true

  before_validation :set_user_values
  before_create :set_state
  before_create :set_creator
  before_update :set_updator

  validates :title, :u_order, presence: true

  default_scope -> { where(deleted_at: nil) }

  #
  #在庁フラグをON/OFF切り替える。
  # ==== Parameters
  # * + new_state -指定のフラグ値('on', 'off')。指定しない場合は現在の状態を反転させる。
  #
  def toggle_state(new_state = nil)
    if new_state
      case new_state.downcase
      when 'on','off'
        update_attribute(:state, new_state)
      else
        update_attribute(:state, 'off')
        raise "Invalid Parameter@PrefDirector::state_change"
      end
    else
      new_state = state == 'on' ? 'off' : 'on'
      update_attribute(:state, new_state)
    end

    Gw::PrefExecutive.where(:uid => uid).update_all(:state => new_state)
    self
  end

  def self.editable?(user = Core.user)
    self.is_admin?(user) || self.is_dev?(user)
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('gw_pref_director/admin', '_admin/admin')
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['在席','on'],['不在','off']]
  end

  def self.state_show(state)
    state_select.rassoc(state).try(:first).to_s
  end

private

  def set_user_values
    return unless uid_changed?
    return unless user

    self.u_code = user.code
    self.u_name = user.name
    if self.title =~ /\A(知事|副知事|政策監|政策監補)\z/
      self.u_lname = self.title
    else
      self.u_lname = nil
    end
    if group = user.groups.first
      self.gid = group.id
      self.g_code = group.code
      self.g_name = group.name
      self.g_order = group.sort_no
      if parent_group = group.parent
        self.parent_gid     = parent_group.id
        self.parent_g_code  = parent_group.code
        self.parent_g_name  = parent_group.name
        self.parent_g_order = parent_group.sort_no
      end
    end
  end

  def set_state
    self.state = 'off'
  end

  def set_creator
    self.created_user  = Core.user.name if Core.user
    self.created_group = Core.user_group.ou_name if Core.user_group
  end

  def set_updator
    self.updated_user  = Core.user.name if Core.user
    self.updated_group = Core.user_group.ou_name if Core.user_group
  end
end
