#require 'digest/sha1'
class System::Role < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Cache::EditLinkPiece

  belongs_to :role_name, :class_name => 'System::RoleName'
  belongs_to :priv_user, :class_name => 'System::PrivName'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

  before_save :before_save_setting_columns

  validates_presence_of :idx, :class_id, :priv
  validates_presence_of :role_name_id
  validates_presence_of :priv_user_id
  validates_numericality_of :idx
  validates_uniqueness_of :role_name_id, :scope => [:priv_user_id, :uid, :priv, :class_id],
    :message => 'と対象権限が登録済みのものと重複しています。'
  validates_presence_of :uid, :if => lambda {|p| p.class_id.to_s != '0' }

  def self.is_dev?(user = Core.user)
    user.has_role?('_admin/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def users
    System::User.select(:id, :name).map{|u| [u.id, u.name]}
  end

  def groups
    items_raw = System::Group.select(:id, :name).order(:code).all.map{|g| [g.id, g.name]}
  end

  def class_id_no
    [['すべて', 0], ['ユーザー', 1], ['グループ', 2]]
  end

  def class_id_label
    class_id_no.rassoc(class_id).try(:first)
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

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'role_id'
        search_id v,:role_name_id unless (v.to_s == '0' || v.to_s == nil)
      when 'priv_id'
        search_id v,:priv_user_id unless (v.to_s == '0' || v.to_s == nil)
      end
    end if params.size != 0
    return self
  end

  def editable?
    return true
  end

  def deletable?
    if table_name.to_s == "_admin"
      # GW管理画面の管理者（システム管理者）が2名以上の場合のみ削除可
      return System::Role.where(:table_name => '_admin', :priv_name => 'admin').count.to_i > 1
    else
      return true
    end
  end

private

  def before_save_setting_columns
    unless self.role_name_id.nil?
      self.table_name = self.role_name.table_name unless self.role_name_id.blank?
    end
    unless self.priv_user_id.nil?
      self.priv_name = self.priv_user.priv_name unless self.priv_user_id.blank?
    end
  end
end
