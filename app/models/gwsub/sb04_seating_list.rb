# -*- encoding: utf-8 -*-
class Gwsub::Sb04SeatingList < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fyear    ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'

  validates_presence_of :fyear_id
  validates_presence_of :title
  validates_presence_of :bbs_url

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.set_f(params_item)
    new_item = params_item
    if params_item[:fyear_id].present?
      fyear = Gw::YearFiscalJp.find(params_item[:fyear_id])
      if fyear.blank?
        new_item[:fyear_markjp] = nil
      else
        new_item[:fyear_markjp] = fyear.markjp
      end
    end
    return new_item
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
        search_keyword v,:fyear_markjp,:title,:bbs_url,:remarks
      when 'fyed_id'
        search_id v,:fyear_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.bbs_docs_link_check(url=nil)
    # 座席表掲示板　記事リンクチェック
    return false if url.blank?
    state     = url.scan(/state=([\w]+(&|\z))/)
    title_id  = url.scan(/title_id=([\d]+)/)
    doc_id    = url.scan(/docs\/([\d]+)/)
    if state.blank?
      # ステータス指定がなければtrue
    else
      state.flatten!
      if state.length > 2
        return false
      else
        if state.length==2 and (state.index("&").blank? and state.index("").blank?)
          return false
        end
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

    title_id.flatten!
    doc_id.flatten!
    title_id = title_id[0]
    doc_id = doc_id[0]
    bbs_board = Gwbbs::Control.find_by_id(title_id)
    # 掲示板がみつからなければurl不正
    return false if bbs_board.blank?

    cnn = Gwbbs::Doc.establish_connection
    cnn.spec.config[:database] = bbs_board.dbname.to_s
    bbs_doc1 = Gwboard::CommonDb.establish_connection(cnn.spec.config)
    bbs_doc1 = Gwbbs::Doc.new
    bbs_doc = bbs_doc1.find(:all,:conditions=>"id=#{doc_id} and state='public'")
    bbs_doc_exist = bbs_doc.count
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
  
  def self.db_alias(item)
    cnn = item.establish_connection

    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec)
    return item
  end

  def self.drop_create_table
    _connect = self.connection()
    _drop_query = "DROP TABLE IF EXISTS `gwsub_sb04_seating_lists` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gwsub_sb04_seating_lists` (
      `id`                  int(11) NOT NULL auto_increment,
      `fyear_id`            int(11) default NULL,
      `fyear_markjp`        text default NULL,
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
    _connect.execute(_create_query)
    return
  end
end
