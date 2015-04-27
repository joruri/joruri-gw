class System::RoleDeveloper < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :role_name, :class_name => 'System::RoleName'
  belongs_to :priv_user, :class_name => 'System::PrivName'
  belongs_to :user, -> { where(System::RoleDeveloper.arel_table[:class_id].eq(1)) }, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, -> { where(System::RoleDeveloper.arel_table[:class_id].eq(2)) }, :foreign_key => :uid, :class_name => 'System::Group'

  before_save :before_save_setting_columns
  after_validation :validate_misc

  validates_presence_of :idx, :class_id, :priv
  validates_presence_of :role_name_id
  validates_presence_of :priv_user_id
  validates_numericality_of :idx
  validates_uniqueness_of :role_name_id, :scope => [:priv_user_id, :uid, :priv]
  validates_presence_of :uid, :if => lambda {|p| p.class_id.to_s != '0' }

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

  def users
    System::User.all.map{|u| [u.id, u.name] }
  end

  def groups
    System::Group.all.order(:code).map{|g| [g.id, g.name]}
  end

  def get(table_name, priv_name)
    self.class.where(:table_name => table_name, :priv_name => priv_name).order(:idx)
  end

  def uid_label
    case self.class_id
    when 1
      user.try(:display_name)
    when 2
      group.try(:display_name)
    end
  end

private

  def validate_misc
    idxisnum = true
    if errors.invalid?(:idx)
      idxisnum = false unless self.idx.blank?
    end
   if errors.invalid?(:role_name_id)
      unless self.role_name_id.blank?
        errors.clear
        errors.add_to_base('すでに登録済です。')
        errors.add_on_blank(:idx)
        errors.add(:idx, 'は数値で入力してください。') unless idxisnum
      end
    end
  end

  def before_save_setting_columns
    unless self.role_name_id.nil?
      self.table_name = self.role_name.table_name unless self.role_name_id.blank?
    end
    unless self.table_name.nil?
      if role_table = System::RoleName.where(:idtable_name=>"#{self.table_name}").first
        self.role_name_id = role_table.id
      end
    end
    unless self.priv_user_id.nil?
      self.priv_name = self.priv_user.priv_name unless self.priv_user_id.blank?
    end
    unless self.priv_name.nil?
      if priv_id = System::PrivName.where(:idpriv_name=>"#{self.priv_name}").first
        self.priv_user_id = priv_id.id
      end
    end
  end
end
