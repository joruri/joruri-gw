class Gwsub::Sb06AssignedHelp < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :fyear_rel   ,:foreign_key=>:fyear_id       ,:class_name=>'Gw::YearFiscalJp'
  belongs_to :cat_rel     ,:foreign_key=>:conf_cat_id    ,:class_name=>'Gwsub::Sb06AssignedConfCategory'
  belongs_to :kind_rel    ,:foreign_key=>:conf_kind_id   ,:class_name=>'Gwsub::Sb06AssignedConfKind'
  belongs_to :group_rel   ,:foreign_key=>:conf_group_id  ,:class_name=>'Gwsub::Sb06AssignedConfGroup'

  validates_presence_of :help_kind
  validates_presence_of :title,:bbs_url
  validates_presence_of :conf_cat_id,:conf_kind_id,:if=>Proc.new{|item| item.help_kind.to_i==2}

  before_save :before_save_setting_columns
  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_save_setting_columns
    if self.help_kind.to_i==2
    else
#      self.fyear_id  = 0
      self.conf_cat_id  = 0
      self.conf_kind_id  = 0
      self.conf_group_id  = 0
    end
    self.fyear_markjp       = self.fyear_rel.markjp             unless self.fyear_id.to_i==0
    self.conf_kind_sort_no  = self.kind_rel.conf_kind_sort_no   unless self.conf_kind_id.to_i==0
    if self.conf_kind_id.to_i==0
    else
      c_group1 = Gwsub::Sb06AssignedConfGroup.new
      c_group1.fyear_id         = self.fyear_id
      c_group1.categories_id    = self.conf_cat_id
      c_group = c_group1.find(:all)
      if c_group.blank?
        self.conf_group_id  = 0
      else
        self.conf_group_id  = c_group[0].id
      end
    end
#    self.conf_group_id      = self.kind_rel.cat.c_grp.id        unless self.conf_kind_id.to_i==0
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.help_kind_dd(all=nil)
    options={:rev=>false}
    target = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_help_kinds',options
    targets = [['すべて','0']] + target if all=='all'
    targets = target unless all=='all'
    return targets
  end
  def self.help_kind_display(kind)
    options={:rev=>true}
    target = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_help_kinds',options
    show = target.assoc(kind)
    return show[1]
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:title,:bbs_url,:remarks
      when 'help_kind'
        search_id v,:help_kind if v.to_i != 0
      when 'c_cat_id'
        search_id v,:conf_cat_id if v.to_i != 0
#      when 'kind_id'
#        search_id v,:conf_kind_id if v.to_i != 0
      when 'c_group_id'
        search_id v,:conf_group_id if v.to_i != 0
      when 'fy_id'
        search_id v,:fyear_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end
  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb06_assigned_helps` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb06_assigned_helps` (
      `id`                  int(11) NOT NULL auto_increment,
      `help_kind`           int(11) default NULL,
      `conf_cat_id`         int(11) default NULL,
      `conf_kind_sort_no`   int(11) default NULL,
      `conf_kind_id`        int(11) default NULL,
      `fyear_id`            int(11) default NULL,
      `fyear_markjp`        text default NULL,
      `conf_group_id`       int(11) default NULL,
      `title`               text default NULL,
      `bbs_url`             text default NULL,
      `remarks`             text default NULL,
      `updated_at`          datetime default NULL,
      `updated_user`        text default NULL,
      `updated_group`       text default NULL,
      `created_at`          datetime default NULL,
      `created_user`        text default NULL,
      `created_group`       text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end

  #
  def state_name
    {'enabled' => '有効', 'disabled' => '無効'}
  end
  def assigned_help_kind
    {1 => '操作説明', 2 => '申請書別説明', 3 => '管理者向け説明'}
  end

end
