class System::Role < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Cache::EditLinkPiece

  belongs_to :role_name, :class_name => 'System::RoleName'
  belongs_to :priv_user, :class_name => 'System::PrivName'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

  before_validation :set_uid
  before_validation :set_table_name
  before_validation :set_priv_name

  validates :role_name_id, presence: true, uniqueness: { scope: [:priv_user_id, :uid, :priv, :class_id], message: 'と対象権限が登録済データと重複しています。'}
  validates :priv_user_id, presence: true
  validates :class_id, :priv, presence: true
  validates :idx, presence: true, numericality: true
  validates :uid, presence: true, unless: :class_id_all?

  scope :roles_for_user, ->(user = Core.user) {
    where([
      arel_table[:class_id].eq(0), 
      arel_table[:class_id].eq(1).and( arel_table[:uid].eq(user.id) ),
      arel_table[:class_id].eq(2).and( arel_table[:uid].in(user.first_group_and_ancestors_ids) )
    ].reduce(:or))
  }

  def self.is_dev?(user = Core.user)
    user.has_role?('_admin/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def class_id_no
    [['すべて', 0], ['ユーザー', 1], ['グループ', 2]]
  end

  def class_id_label
    class_id_no.rassoc(class_id).try(:first)
  end

  def class_id_all?
    class_id == 0
  end

  def priv_no
    [['不可', 0],['許可', 1]]
  end

  def priv_label
    priv_no.rassoc(priv).try(:first)
  end

  def uid_label
    case self.class_id
    when 1
      user.try(:display_name)
    when 2
      group.try(:display_name)
    end
  end

  def get(table_name, priv_name)
    self.class.where(:table_name => table_name, :priv_name => priv_name).order(:idx)
  end

  def role_name_options(user = Core.user)
    roles = 
      if System::Role.is_dev?(user)
        System::RoleName.all.order(sort_no: :asc)
      else
        System::RoleName.where.not(table_name: "gwsub").order(sort_no: :asc)
      end
    roles.map{|r| [r.display_name, r.id] }
  end

  def priv_name_options
    privs = System::RoleNamePriv.joins(:priv).where(role_id: self.role_name_id).order("system_priv_names.sort_no")
    privs.map {|p| [p.priv.try(:display_name), p.priv_id] }
  end

  def editable?
    return true
  end

  def deletable?
    if table_name.to_s == "_admin"
      # GW管理画面の管理者（システム管理者）が2名以上の場合のみ削除可
      return System::Role.where(table_name: '_admin', priv_name: 'admin').count.to_i > 1
    else
      return true
    end
  end

private

  def set_table_name
    if self.role_name
      self.table_name = self.role_name.table_name
    end
  end

  def set_priv_name
    if self.priv_user
      self.priv_name = self.priv_user.priv_name
    end
  end

  def set_uid
    if self.class_id != 1
      self.uid = self.group_id
    end
  end
end
