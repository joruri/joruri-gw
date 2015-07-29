# encoding: utf-8
#require 'digest/sha1'
class System::Role < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include Cms::Model::Base::Content
  include System::Model::Base::Content

  validates_presence_of     :idx, :class_id, :priv
  validates_presence_of     :role_name_id
  validates_presence_of     :priv_user_id

  validates_numericality_of :idx

  validates_uniqueness_of :role_name_id, :scope => [:priv_user_id, :uid, :priv, :class_id],:message=>'と対象権限が登録済みのものと重複しています。'
  validates_presence_of :uid, :if => Proc.new {|p| p.class_id.to_s != '0' }

  belongs_to :role_name  ,:class_name=>'System::RoleName'
  belongs_to :priv_user  ,:class_name=>'System::PrivName'
  belongs_to :user,  :foreign_key=>:uid,:class_name=>'System::User', :conditions => 'class_id = 1'
  belongs_to :group, :foreign_key=>:uid,:class_name=>'System::Group', :conditions => 'class_id = 2'


  before_save :before_save_setting_columns

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'_admin', 'developer')
  end
  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'_admin', 'admin')
  end

  def before_save_setting_columns
    unless self.role_name_id.nil?
      self.table_name = self.role_name.table_name unless self.role_name_id.blank?
    end
    unless self.priv_user_id.nil?
      self.priv_name = self.priv_user.priv_name unless self.priv_user_id.blank?
    end
  end

  def role_classes
     Gw.yaml_to_array_for_select('system_role_classes')
  end

  def users
    users_raw = System::User.find(:all)
    users_list = users_raw.collect{|x|[x['id'], x['name']]}
    return users_list
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

  def editable?
      return true
  end

  def deletable?
    if self.table_name.to_s == "_admin"
      # GW管理画面の管理者（システム管理者）が１名の場合は削除不可
      c_priv = "table_name='_admin' and priv_name='admin'"
      count = System::Role.count(:all , :conditions=>c_priv)
      return false if count.to_i < 2
      return true
    else
      return true
    end
  end

end
