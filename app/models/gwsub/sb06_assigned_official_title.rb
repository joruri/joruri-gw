class Gwsub::Sb06AssignedOfficialTitle < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many  :a_confs      ,:foreign_key=>:official_title_id ,:class_name => 'Gwsub::Sb06AssignedConference'

  validates_presence_of :official_title_code,:official_title_name
  validates_uniqueness_of :official_title_code ,:message=>'は登録済です。'
  validates_uniqueness_of :official_title_name ,:message=>'は登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb06_official_title_id_select(options={})
    # options
    # :all 'all' 選択肢に「すべて」を表示
    # :code 1:表示にコードを付与
    order = "official_title_sort_no,official_title_code"
    item = Gwsub::Sb06AssignedOfficialTitle.new
    items = item.find(:all,:order=>order)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    items.each do |g|
      selects << [g.official_title_name ,g.id] if ( !options[:code] or options[:code].to_i!=1 )
      selects << ['('+g.official_title_code+')'+g.official_title_name ,g.id] if options[:code].to_i==1
    end
    return selects
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:official_title_code,:official_title_name
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb06_assigned_official_titles` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb06_assigned_official_titles` (
      `id`                      int(11) NOT NULL auto_increment,
      `official_title_code`     text default NULL,
      `official_title_name`     text default NULL,
      `official_title_sort_no`  int(11) default NULL,
      `updated_at`              datetime default NULL,
      `updated_user`            text default NULL,
      `updated_group`           text default NULL,
      `created_at`              datetime default NULL,
      `created_user`            text default NULL,
      `created_group`           text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end
end
