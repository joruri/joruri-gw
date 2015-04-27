class Gwsub::Sb00ConferenceReference < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :fy    ,:foreign_key=>:fyear_id      ,:class_name => 'Gw::YearFiscalJp'
  belongs_to :grp   ,:foreign_key=>:group_id      ,:class_name => 'System::GroupHistory'

  validates_presence_of :fyear_id
  validates_presence_of :kind_code
  validates_presence_of :kind_name
  #validates_presence_of :title
  validates_presence_of :group_id

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
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:title
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb00_conference_references` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb00_conference_references` (
      `id`                  int(11) NOT NULL auto_increment,
      `fyear_id`            int(11) default NULL,
      `fyear_markjp`        text default NULL,
      `kind_code`           text default NULL,
      `kind_name`           text default NULL,
      `title`               text default NULL,
      `group_id`            int(11) default NULL,
      `created_at`          datetime default NULL,
      `created_user`        text default NULL,
      `created_group`       text default NULL,
      `updated_at`          datetime default NULL,
      `updated_user`        text default NULL,
      `updated_group`       text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end
end
