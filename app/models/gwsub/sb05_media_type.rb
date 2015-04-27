class Gwsub::Sb05MediaType < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many :m_rel1  ,:foreign_key=>:media_id  ,:class_name=>'Gwsub::Sb05Notice'
  has_many :m_rel2  ,:foreign_key=>:media_id  ,:class_name=>'Gwsub::Sb05Request'
  has_many :m_rel3  ,:foreign_key=>:media_id  ,:class_name=>'Gwsub::Sb05DesiredDate'

  validates_presence_of     :media_code,:media_name,:categories_code,:categories_name
  validates_presence_of     :max_size ,:if=>Proc.new{|item| item.media_name=='メルマガ' && item.categories_name=='イベント情報'}
  # 重複チェックは有効なものを対象に行う
  validates_uniqueness_of   :categories_code ,:scope=>:media_code ,:if=>Proc.new{|item| item.state==1}
  validates_uniqueness_of   :categories_name ,:scope=>:media_code ,:if=>Proc.new{|item| item.state==1}

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.before_validates_setting(params)
    set_params=params
    set_params[:item]['media_name'] = Gwsub::Sb05MediaType.get_media_name(set_params[:item]['media_code'])
    set_params[:item]['max_size'] = nil unless (set_params[:item]['media_name']=='メルマガ' && set_params[:item]['categories_name']=='イベント情報')
    return set_params
  end

  def self.get_media_name(code)
    list = Gw.yaml_to_array_for_select("gwsub_sb05_media_codes")
    list.each{|a| return a[0] if a[1].to_i == code.to_i}
    return nil
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb05_media_state
    return [['有効',1],['無効',2]]
  end
  def self.sb05_media_state_show(state=1)
    case state
    when 1
      show_state = '有効'
    when 2
      show_state = '無効'
    when 3
      show_state = '削除'
    else
      show_state = '無効'
    end
    return show_state
  end

  def self.select_dd_media_group(all = nil,opt=nil)
    media_list = []
    media_list << ['すべて',0] if all == 'all'
    media_list.concat(Gw.yaml_to_array_for_select("gwsub_sb05_media_codes"))
    #medias = Gwsub::Sb05MediaType.order("media_code ASC").group("media_code").where("state=1")
    #case opt
    #when 'code'
    #  medias.each do |m|
    #    media_list << [m.media_name,m.media_code]
    #  end
    #else # id
    #  medias.each do |m|
    #    media_list << [m.media_name,m.media_id]
    #  end
    #end

    return media_list
  end
  def self.cats(media_code = nil,all = nil)
    category = Gwsub::Sb05MediaType.new
    category.state = 1
    category.media_code = media_code unless (media_code.blank? || media_code.to_i == 0)
    category.order "media_code ASC , categories_code ASC"
    categories = category.find(:all)
    return categories
  end
  def self.select_dd_categories_id(media_code=nil,all = nil)
    cat_list = []
    cat_list << ['すべて',0] if all == 'all'
    category = Gwsub::Sb05MediaType.new
    category.state = 1
    category.media_code = media_code unless (media_code.blank? || media_code.to_i == 0)
    category.order "media_code ASC , categories_code ASC"
    categories = category.find(:all)
    categories.each do |m|
      cat_list << [m.media_name+'('+m.categories_name+')',m.id]
    end
    return cat_list
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :media_code,:media_name,:categories_code,:categories_name
      when 'media_id'
        search_id v, :id if v.to_i!=0
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb05_media_types` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb05_media_types` (
      `id`                int(11) NOT NULL auto_increment,
      `media_code`        int(11) default NULL,
      `media_name`        text default NULL,
      `categories_code`   int(11) default NULL,
      `categories_name`   text default NULL,
      `max_size`          int(11) default NULL,
      `state`             int(11) default NULL,
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
