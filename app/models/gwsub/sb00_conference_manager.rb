class Gwsub::Sb00ConferenceManager < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :fy        ,:foreign_key=>:fyear_id      ,:class_name => 'Gw::YearFiscalJp'
  belongs_to :grp1      ,:foreign_key=>:group_id      ,:class_name => 'System::GroupHistory'
  belongs_to :user1     ,:foreign_key=>:user_id       ,:class_name => 'System::User'

  validates_presence_of :fyear_id
  validates_presence_of :group_id
  validates_presence_of :user_id
  validates_presence_of :memo_str

  # 管理者は、機能・年度・所属でユニーク
  validates_uniqueness_of :user_id,         :scope => [:controler,:fyear_id,:group_id]  ,:message=>"は登録済です。"

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('sb00/admin')
  end

  def before_save_setting_columns
    unless self.fyear_id.to_i==0
      self.fyear_markjp = self.fy.markjp
    end
    unless self.group_id.to_i==0
      self.group_code = self.grp1.code
      self.group_name = self.grp1.name
    end
    unless self.user_id.to_i==0
      self.user_code = self.user1.code
      self.user_name = self.user1.name
    end
    unless self.controler.to_s.blank?
      self.controler_title = Gwsub::Sb00ConferenceManager.ctrl_show(self.controler)
    end
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end


  def self.ctrl_select(all=nil)
    ctrl =  Gw.yaml_to_array_for_select 'gwsub_sb00_conference_manager_controlers'
    ctrls = [['all',0]] + ctrl if all=='all'
    ctrls = ctrl unless all=='all'
    return ctrls
  end
  def self.ctrl_show(ctrl=nil)
    options = {:rev => true}
    ctrl1 =  Gw.yaml_to_array_for_select 'gwsub_sb00_conference_manager_controlers',options
    ctrl_show = ctrl1.assoc(ctrl)
    return ctrl_show[1] unless ctrl_show.blank?
    return nil          if ctrl_show.blank?
  end

  def self.send_states
    states =  Gw.yaml_to_array_for_select 'gwsub_sb00_conference_managers_state'
    return states
  end
  def self.send_state_show(state=nil)
    options = {:rev => true}
    states =  Gw.yaml_to_array_for_select 'gwsub_sb00_conference_managers_state',options
    states_show = states.assoc(state.to_i)
    return states_show[1] unless states_show.blank?
    return nil            if states_show.blank?
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:group_name,:user_name,:memo_str
      when 'ctrl'
        #search_equal v.to_s,:controler
        search_keyword v.to_s,:controler
      when 'fy_id'
        search_id v,:fyear_id  unless v.to_i==0
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb00_conference_managers` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb00_conference_managers` (
      `id` int(11) NOT NULL auto_increment,
      `controler` text,
      `controler_title` text,
      `memo_str` text,
      `fyear_id` int(11) default NULL,
      `fyear_markjp` text,
      `group_id` int(11) default NULL,
      `group_code` text,
      `group_name` text,
      `user_id` int(11) default NULL,
      `user_code` text,
      `user_name` text,
      `official_title_id` int(11) default NULL,
      `official_title_name` text,
      `send_state` text,
      `updated_at` datetime default NULL,
      `updated_user` text,
      `updated_group` text,
      `created_at` datetime default NULL,
      `created_user` text,
      `created_group` text,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end
end
