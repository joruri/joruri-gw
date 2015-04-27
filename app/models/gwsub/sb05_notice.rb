class Gwsub::Sb05Notice < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :m_rel    ,:foreign_key=>:media_id         ,:class_name=>'Gwsub::Sb05MediaType'

  validates_presence_of   :media_id
  validates_uniqueness_of :media_id ,:message=>'のヘルプは、すでに登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :set_medias

  def set_medias
    media = Gwsub::Sb05MediaType.find(self.media_id)
    self.media_code = media.media_code
    self.media_name = media.media_name
    self.categories_code = media.categories_code
    self.categories_name = media.categories_name
    self.form_templates = Gwsub.num_zen_to_han(self.form_templates)
    self.form_templates = Gwsub.space_del(self.form_templates)
    self.form_templates = Gwsub.rep_space(self.form_templates)
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
        search_keyword v, :media_name,:categories_name,:sample,:remarks,:form_templates
      when 'media'
        search_keyword v, :media_name
      when 'media_id'
        search_id v, :media_id if v.to_i != 0
      when 'media_code'
        search_id v, :media_code if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb05_notices` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb05_notices` (
      `id`                int(11) NOT NULL auto_increment,
      `media_id`          int(11) default NULL,
      `media_code`        int(11) default NULL,
      `media_name`        text default NULL,
      `categories_code`   int(11) default NULL,
      `categories_name`   text default NULL,
      `sample`            text default NULL,
      `remarks`           text default NULL,
      `form_templates`    text default NULL,
      `admin_remarks`     text default NULL,
      `updated_at`        datetime default NULL,
      `updated_user`      text default NULL,
      `updated_group`     text default NULL,
      `created_at`        datetime default NULL,
      `created_user`      text default NULL,
      `created_group`     text default NULL,
      PRIMARY KEY  (`id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end
end
