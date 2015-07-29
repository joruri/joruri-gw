# -*- encoding: utf-8 -*-
class Gwsub::Sb01TrainingGuide  < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fyear           ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'
  #has_many :training_schedule ,:class_name=>'Gwsub::Sb01TrainingScheduleProp'
  #has_many :schedule          , :through => :training_schedule

  validates_presence_of :categories
  validates_presence_of :fyear_id
  validates_presence_of :title
  validates_presence_of :bbs_url

#  validates_uniqueness_of :categories , :scope => [:fyear_id,:bbs_url] ,:message=>'は、年度内で登録済です。'
  validates_uniqueness_of :title      , :scope => [:fyear_id,:bbs_url] ,:message=>'が、年度内で重複しています。'

  before_save :before_save_setting_columns
  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'gwsub', 'developer')
  end
  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'sb01', 'admin')
  end
  def self.is_editor?(org_code , g_code = Site.user_group.group_code)
    return false unless g_code.to_s == org_code.to_s
    return true
  end
  def category_no
    [['受講者向け利用の手引き',1],['企画者向け利用の手引き',2],['管理者向け利用の手引き',3]]
  end

  def category_label
    category_no.each {|a| return a[0] if a[1] == categories.to_i }
    return nil
  end

  def self.state_list
    Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
  end
  def self.state_show(state)
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
    states = []
    list2.each do |value , key|
      states << [key,value]
    end
    show = states.assoc(state.to_s)
    return show[1]
  end
  def self.state_select(all=nil)
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
    lists = []
    if all=='all'
      lists.push ['すべて','0']
    end
    lists = lists + list2
    return lists
  end

  def self.select_cats(all=nil)
    lists = []
    if all=='all'
      lists.push ['すべて','0']
    end
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_help_categories'
    lists = lists + list2
    return lists
  end
  def self.show_cats(categories)
    if categories.to_s == '0'
      return 'すべて'
    end
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_help_categories'
    cats = []
    list2.each do |value , key|
      cats << [key,value]
    end
    show = cats.assoc(categories.to_s)
    return show[1]
  end

  def self.select_titles(options={})
    title = Gwsub::Sb01Training.new
    title.categories = '1'
    title.order "fyear_markjp DESC , updated_at DESC"
    titles = title.find(:all)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    titles.each do |t|
      selects << [t.title,t.id]
    end
    return selects
  end

  def self.set_f(params_item)
    new_item = params_item
    fyear = Gw::YearFiscalJp.find(params_item['fyear_id'])
    new_item['fyear_markjp'] = fyear.markjp
    return new_item
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end
  def before_save_setting_columns
    self.member_id  = Site.user.id
    self.group_id   = Site.user_group.id
  end

  def self.bbs_docs_link_check(url=nil)
    return false if url.blank?
    state     = url.scan(/state=([\w]+(&|\z))/)
    title_id  = url.scan(/title_id=([\d]+)/)
    doc_id    = url.scan(/docs\/([\d]+)/)
#pp url,state,title_id,doc_id
    if state.blank?
      # ステータス指定がなければtrue
    else
      state.flatten!
      state.delete_if {|x| x.blank? }
      state.delete_if {|x| x== "&"}
      if state.length > 1
        return false
#      else
#        if state.length==2 and state.index("&").blank?
#          return false
#        end
      end
      if state.index("DATE").blank?
      if state.index("DATE&").blank?
      if state.index("GROUP").blank?
      if state.index("GROUP&").blank?
      if state.index("CATEGORY").blank?
      if state.index("CATEGORY&").blank?
#        # 公開画面のステータス以外はfalse
        return false
      end
      end
      end
      end
      end
      end
    end
    # 該当の掲示板・記事について、idがなければURL不正
    return false if title_id.blank?
    return false if doc_id.blank?

    bbs_board_exist = Gwbbs::Control.count(:all,:conditions=>"id=#{title_id}")
    # 掲示板がみつからなければurl不正
    return false if bbs_board_exist==0
    bbs_board = Gwbbs::Control.find(:all,:conditions=>"id=#{title_id}")

    cnn = Gwbbs::Doc.establish_connection
    cnn.spec.config[:database] = bbs_board[0].dbname.to_s
    bbs_doc1 = Gwboard::CommonDb.establish_connection(cnn.spec)
    bbs_doc1 = Gwbbs::Doc.new
    bbs_doc_exist = bbs_doc1.count(:all,:conditions=>"id=#{doc_id} and state='public'")
    # 公開記事がみつからなければ、リンクきれ
    return false if bbs_doc_exist==0
    # 期限切れは、見せないので、リンクを切る
    bbs_docs = bbs_doc1.find(:all,:conditions=>"id=#{doc_id} and state='public'")
    return false if bbs_docs.blank?
    from_at   = bbs_docs[0].able_date
    to_at     = bbs_docs[0].expiry_date
    if Time.now < from_at
      return false
    end
    if Time.now > to_at
      return false
    end
    return true
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:title,:bbs_url,:remarks
      when 'cat'
        search_equal v,:categories unless (v.to_s == '0' || v.to_s == nil)
      when 'g_id'
        search_id v,:group_id unless (v.to_s == '0' || v.to_s == nil)
      end
    end if params.size != 0

    return self
  end
#  def self.drop_create_table
#    # catgories : 掲示板分類（1:研修案内・2:受講者向け利用方法・3:企画者向け利用方法）
#    connect = self.connection()
#    drop_query = "DROP TABLE IF EXISTS `gwsub_sb01_trainings` ;"
#    connect.execute(drop_query)
#    create_query = "CREATE TABLE `gwsub_sb01_trainings` (
#      `id`                  int(11) NOT NULL auto_increment,
#      `categories`          text default NULL,
#      `fyear_id`            int(11) default NULL,
#      `fyear_markjp`        text default NULL,
#      `title`               text default NULL,
#      `bbs_url`             text default NULL,
#      `remarks`             text default NULL,
#      `state`               text default NULL,
#      `member_id`           int(11) default NULL,
#      `group_id`            int(11) default NULL,
#      `updated_at`          datetime default NULL,
#      `updated_user`        text default NULL,
#      `updated_group`       text default NULL,
#      `created_at`          datetime default NULL,
#      `created_user`        text default NULL,
#      `created_group`       text default NULL,
#      PRIMARY KEY  (`id`)
#    ) DEFAULT CHARSET=utf8;"
#    connect.execute(create_query)
#    return
#  end
end
