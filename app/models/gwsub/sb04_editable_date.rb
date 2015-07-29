# -*- encoding: utf-8 -*-
class Gwsub::Sb04EditableDate < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fy_rel    ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'

#  validates_presence_of :fyear_id
#  validates_presence_of :published_at
  validates_presence_of :start_at
  validates_presence_of :end_at
  validates_presence_of :headline_at

  validates_uniqueness_of :fyear_id  ,:message=>'は、登録済です。'
#  validates_each :published_at,:start_at,:end_at do |record, attr, value|
  validates_each :start_at,:end_at,:headline_at do |record, attr, value|
    record.errors.add attr, 'は、指定年度内の日付ではありません。' if !value.to_s.blank? and (Gw.date_str(value) < Gw.date_str(record.fy_rel.start_at) or Gw.date_str(value) > Gw.date_str(record.fy_rel.end_at))
  end
#  validates_each :start_at,:end_at do |record, attr, value|
#    record.errors.add attr, 'は、公開開始日より後の日付を入力して下さい。' if !value.to_s.blank? and Gw.date_str(value) <= Gw.date_str(record.published_at)
#  end
  validates_each :end_at do |record, attr, value|
    record.errors.add attr, 'は、編集開始日時より後の日時を指定して下さい。' if !value.to_s.blank? and Gw.datetime_str(value) < Gw.datetime_str(record.start_at)
  end

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.set_f(params_item)
    new_item = params_item
    fyear = Gw::YearFiscalJp.find(params_item['fyear_id'])
    new_item['fyear_markjp']  = fyear.markjp
    new_item['published_at']  = Gw.datetime_str(new_item['start_at'])
    new_item['start_at']      = Gw.datetime_str(new_item['start_at'])
    new_item['end_at']        = Gw.datetime_str(new_item['end_at'])
    new_item['headline_at']   = Gw.date_common(new_item['headline_at'])+" 00:00:00"
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
        search_keyword v,:fyear_markjp,:headline_at,:start_at,:end_at
      when 'fyed_id'
        search_id v,:fyear_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end
  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb04_editable_dates` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb04_editable_dates` (
      `id`                  int(11) NOT NULL auto_increment,
      `fyear_id`            int(11) default NULL,
      `fyear_markjp`        text default NULL,
      `published_at`        datetime default NULL,
      `start_at`            datetime default NULL,
      `end_at`              datetime default NULL,
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
  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gwsub_sb04_editable_dates` ;"
    connect.execute(truncate_query)
  end
  def self.today_published?(fyear_id = 0)
    # 当日が、公開しているかどうか選択
      today = Core.now
      find_cond = "published_at <='#{today}' and fyear_id = #{fyear_id}"
      find_order = "start_at DESC"
      find_year = Gwsub::Sb04EditableDate.find(:first,:conditions=>find_cond,:order=>find_order)
      if find_year.blank?
        return false
      else
        return true
      end
  end
  def self.today_edit_period?(fyear_id = 0)
    # 当日が、編集期間中かどうか確認する
      today = Core.now
      find_cond = "start_at <= '#{today}' and '#{today}' <= end_at and fyear_id = #{fyear_id}"
      find_order = "start_at DESC"
      find_year = Gwsub::Sb04EditableDate.find(:first,:conditions=>find_cond,:order=>find_order)
      if find_year.blank?
        return false
      else
        return true
      end
  end
end
