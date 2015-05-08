class Gw::PrefAssemblyMember < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::UnameAndGid

  has_many :group_members, :foreign_key => :g_order, :primary_key => :g_order, :class_name => self.name

  validates :g_name, :g_order, :u_name, :u_lname, :u_order, presence: true

  default_scope -> { where(deleted_at: nil) }

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['在席','on'],['不在','off']]
  end

  def self.state_show(state)
    state_select.rassoc(state).try(:first)
  end

  #議長レコードを抽出する。議長は g_order = 10 のレコード
  def self.get_chairman
    self.where(:g_order => 10)
  end

  #副議長レコードを抽出する。副議長は g_order = 20 のレコード
  def self.get_vicechairmen
    self.where(:g_order => 20)
  end

  #議員一覧を抽出する。議員は g_order > 20 のレコード
  def self.get_members
    self.where(arel_table[:g_order].gt(20))
  end

  #
  #在庁フラグをON/OFF切り替える。
  # ==== Parameters
  # * + new_state -指定のフラグ値('on', 'off')。指定しない場合は現在の状態を反転させる。
  #
  def toggle_state(new_state = nil)
    if new_state
      case new_state.downcase
      when 'on','off'
        update_column(:state, new_state)
      else
        #'on','off'以外は'off'にして例外をスローする
        update_column(:state, 'off')
        raise "Invalid Parameter@PrefAssemblyMember::state_change"
      end
    else
      #現在の状態の反転
      update_column(:state, state == 'on' ? 'off' : 'on')
    end
    self
  end

  def self.editable?(user = Core.user)
    self.is_admin?(user) || self.is_dev?(user)
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('gw_pref_assembly/admin', '_admin/admin')
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end
end
