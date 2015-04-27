class Gwsub::Sb06BudgetEditableDate < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

#  belongs_to :fy_rel    ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'

  validates_presence_of :start_at
  validates_presence_of :end_at
  validates_presence_of :recognize_at

  # 対象年度は、編集開始日で判定
  validates_each :start_at,:end_at,:recognize_at do |record, attr, value|
    record.errors.add attr, 'は、指定年度内の日付ではありません。' if !value.to_s.blank? and (Gw.date_str(value) < Gw.date_str(Gw::YearFiscalJp.get_record(record.start_at).start_at) or Gw.date_str(value) > Gw.date_str(Gw::YearFiscalJp.get_record(record.start_at).end_at))
  end
  validates_each :end_at do |record, attr, value|
    record.errors.add attr, 'は、編集開始日より後の日付を入力して下さい。' if !value.to_s.blank? and Gw.date_str(value) <= Gw.date_str(record.start_at)
  end
  validates_each :recognize_at do |record, attr, value|
    record.errors.add attr, 'は、編集終了日より後の日付を入力して下さい。' if !value.to_s.blank? and !record.end_at.blank? and Gw.date_str(value) <= Gw.date_str(record.end_at)
  end

  #  before_save :before_save_setting_columns
  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.set_f(params_item)
    new_item = params_item
    new_item['start_at']        = Gw.date_common(new_item['start_at'])+" 00:00:00"
    new_item['end_at']          = Gw.date_common(new_item['end_at'])+" 23:59:59"
    new_item['recognize_at']    = Gw.date_common(new_item['recognize_at'])+" 23:59:59"
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
        search_keyword v,:start_at,:end_at
      end
    end if params.size != 0

    return self
  end
  def self.drop_create_table
    connect = self.connection()
    drop_query = "DROP TABLE IF EXISTS `gwsub_sb06_budget_editable_dates` ;"
    connect.execute(drop_query)
    create_query = "CREATE TABLE `gwsub_sb06_budget_editable_dates` (
      `id`                  int(11) NOT NULL auto_increment,
      `start_at`            datetime default NULL,
      `end_at`              datetime default NULL,
      `recognize_at`        datetime default NULL,
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
end
