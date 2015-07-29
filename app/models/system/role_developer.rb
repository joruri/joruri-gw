# encoding: utf-8
class System::RoleDeveloper < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  validates_presence_of     :idx, :class_id, :priv
  validates_presence_of     :role_name_id
  validates_presence_of     :priv_user_id

  validates_numericality_of :idx

  validates_uniqueness_of :role_name_id, :scope => [:priv_user_id, :uid, :priv]
  validates_presence_of :uid, :if => Proc.new {|p| p.class_id.to_s != '0' }

  belongs_to :role_name  ,:class_name=>'System::RoleName'
  belongs_to :priv_user  ,:class_name=>'System::PrivName'
  belongs_to :user,  :foreign_key=>:uid,:class_name=>'System::User', :conditions => 'class_id = 1'
  belongs_to :group, :foreign_key=>:uid,:class_name=>'System::Group', :conditions => 'class_id = 2'

  before_save :before_save_setting_columns

  def after_validation
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
      if role_table = System::RoleName.find_by_table_name("#{self.table_name}")
        self.role_name_id = role_table.id
      end
    end
    unless self.priv_user_id.nil?
      self.priv_name = self.priv_user.priv_name unless self.priv_user_id.blank?
    end
    unless self.priv_name.nil?
      if priv_id = System::PrivName.find_by_priv_name("#{self.priv_name}")
        self.priv_user_id = priv_id.id
      end
    end
  end

  def role_classes
     Gw.yaml_to_array_for_select('system_role_classes')
  end

  def users
    users_raw = System::User.find(:all)
    users = users_raw.collect{|x|[x['id'], x['name']]}
    return users
  end

  def groups
    items_raw = System::Group.find(:all, :order=>'code')
    items = []
    items_raw.each do |item_raw|
      items.push [item_raw['id'], item_raw['name']]
    end
    return items
  end

  def privs
    Gw.yaml_to_array_for_select('t1f0_kyoka_fuka')
  end

  def get(table_name, priv_name)
    self.find :all, :order=>'idx', :conditions => { :table_name => table_name, :priv_name => priv_name }
  end

  def self.td_criteria
    {
      'uid' => Proc.new{|item|
        case item.class_id
        when 1
          "#{Gw::Model::Schedule.get_uname :uid=>item.uid}"
        when 2
          "#{Gw::Model::Schedule.get_gname :gid=>item.uid}"
        else
          ''
        end
      }
    }
  end

  def class_id_no
    [['すべて', 0], ['ユーザー', 1], ['グループ', 2]]
  end

  def class_id_label
    class_id_no.each {|a| return a[0] if a[1] == class_id }
    return nil
  end

  def priv_no
    [['不可', 0],['許可', 1]]
  end

  def priv_label
    priv_no.each {|a| return a[0] if a[1] == priv }
    return nil
  end

  def uid_label
    label = ''
      case self.class_id
      when 1
        label = Gw::Model::Schedule.get_uname :uid=>self.uid
      when 2
        label = Gw::Model::Schedule.get_gname :gid=>self.uid
      end
    return label
  end
end
