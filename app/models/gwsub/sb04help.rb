# -*- encoding: utf-8 -*-
class Gwsub::Sb04help < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content


  validates_presence_of :categories,:title,:bbs_url

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.select_help_categories
    options     = {:rev => false}
    cats = Gw.yaml_to_array_for_select 'gwsub_sb04_help_categories',options
    return cats
  end
  def self.select_help_categories_show(cat)
    options     = {:rev => true}
    cats = Gw.yaml_to_array_for_select 'gwsub_sb04_help_categories',options
    state_show  = cats.assoc(cat)
    if      state_show.blank?
      return nil
    else
      return state_show[1]
    end
  end

  def search(params)

    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v,:title,:bbs_url,:remarks
      end if params.size != 0
    end
    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb04helps` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb04helps` (
      `id`                  int(11) NOT NULL auto_increment,
      `categories`          int(11) default NULL,
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
    ) DEFAULT CHARSET=utf8;"
    connect.execute(create_query)
    return
  end

end
