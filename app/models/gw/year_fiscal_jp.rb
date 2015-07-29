# encoding: utf-8
class Gw::YearFiscalJp < Gw::Database
  include System::Model::Base
  include Cms::Model::Base::Content

  validates_presence_of :fyear
  validates_uniqueness_of :fyear ,:unless=>Proc.new{|item| item.fyear.blank?}
  validates_numericality_of :fyear ,:unless=>Proc.new{|item| item.fyear.blank?}
  validates_length_of :fyear, :is => 4 ,:unless=>Proc.new{|item| item.fyear.blank?}
  
  after_validation :set_f
  
  def set_f
    start_at_temp = "#{self.fyear.to_i}-04-01 00:00:00"
    end_at_temp = "#{self.fyear.to_i+1}-03-31 23:59:59"
    marks = Gw::YearMarkJp.convert_ytoj(start_at_temp, '4')
    unless marks
      errors.add(:fyear, "に対応する年号が設定されていません。")
      return false
    end
    
    self.start_at = start_at_temp
    self.end_at   = end_at_temp
    
    self.markjp = marks[1]
    self.namejp = marks[2]
    str_fiscal = '年度'
    self.fyear_f  = self.fyear.to_s + str_fiscal
    self.markjp_f = self.markjp.to_s + str_fiscal
    self.namejp_f = self.namejp.to_s + str_fiscal
  end

  def self.get_next_year_record(start_at)
    begin
      pd = Gw::YearFiscalJp.date_check(start_at)
    rescue
      return nil
    end
    if pd[1].to_i < 4
      next_year = pd[0].to_i
    else
      next_year = pd[0].to_i + 1
    end
    order = "start_at ASC"
    cond = "start_at >= '#{next_year}-04-01 00:00:00'"
    item = Gw::YearFiscalJp.find(:first,:conditions=>cond,:order=>order)
    return item
  end

  def self.get_record(start_at)
    begin
      pd = Gw::YearFiscalJp.date_check(start_at)
    rescue
      return nil
    end
    order = "start_at DESC"
    cond = "start_at <= '#{pd[0]}-#{pd[1]}-#{pd[2]} 00:00:00'"
    item = Gw::YearFiscalJp.find(:first,:conditions=>cond,:order=>order)
    return item
  end

  def self.date_check(fyear_start_at)
    pd=[]
		x = nil
    begin
      if fyear_start_at.is_a?(Date) || fyear_start_at.is_a?(Time)
				x = fyear_start_at
      elsif fyear_start_at.is_a?(String)
        x = Date.parse(fyear_start_at, true)
			else
				raise TypeError, "cannot recognize datetime format(#{fyear_start_at})"
      end
    end

    pd[0] = sprintf("%4d", x.year)
    pd[1] = sprintf("%02d", x.mon)
    pd[2] = sprintf("%02d", x.mday)
    return pd
  end

  def self.select_dd_fyear_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.fyear,item.id]
    end
    return dd_lists
  end

  def self.select_dd_fyear_fyear(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.fyear,item.fyear]
    end
    return dd_lists
  end

  def self.select_dd_fyearf_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.fyear_f,item.id]
    end
    return dd_lists
  end
  def self.select_dd_fyearf_fyearf(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.fyear_f,item.fyear_f]
    end
    return dd_lists
  end

  def self.select_dd_markjp_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.markjp,item.id]
    end
    return dd_lists
  end

  def self.select_dd_markjp_markjp(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.markjp,item.markjp]
    end
    return dd_lists
  end

  def self.select_dd_markjp_fyear(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.markjp,item.fyear.to_i]
    end
    return dd_lists
  end

  def self.select_dd_markjpf_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.markjp_f,item.id]
    end
    return dd_lists
  end

  def self.select_dd_markjpf_markjpf(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.markjp_f,item.markjp_f]
    end
    return dd_lists
  end

  def self.select_dd_namejp_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.namejp,item.id]
    end
    return dd_lists
  end

  def self.select_dd_namejp_namejp(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.namejp,item.namejp]
    end
    return dd_lists
  end

  def self.select_dd_namejpf_id(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.namejp_f,item.id]
    end
    return dd_lists
  end

  def self.select_dd_namejpf_namejpf(all = nil,limit=nil)
    dd_lists = []
    dd_lists << ['すべて','すべて'] if all == 'all'
    order = "fyear DESC , start_at DESC"
    items = Gw::YearFiscalJp.find(:all,:order=>order) if limit.blank?
    items = Gw::YearFiscalJp.find(:all,:order=>order,:limit=>limit.to_i) unless limit.blank?
    return dd_lists if items.blank?
    items.each do |item|
      dd_lists << [item.namejp_f,item.namejp_f]
    end
    return dd_lists
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :fyear,:markjp,:namejp
      end
    end if params.size != 0

    return self
  end

  def self.drop_create_table
    _connect = self.connection()
    _drop_query = "DROP TABLE IF EXISTS `gw_year_fiscal_jps` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gw_year_fiscal_jps` (
      `id`            int(11)  NOT NULL auto_increment,
      `start_at`      datetime default NULL,
      `end_at`        datetime default NULL,
      `fyear`         text     default NULL,
      `fyear_f`       text     default NULL,
      `markjp`        text     default NULL,
      `markjp_f`      text     default NULL,
      `namejp`        text     default NULL,
      `namejp_f`      text     default NULL,
      `updated_at`    datetime default NULL,
      `updated_user`  text     default NULL,
      `updated_group` text     default NULL,
      `created_at`    datetime default NULL,
      `created_user`  text     default NULL,
      `created_group` text     default NULL,
      PRIMARY KEY  (`id`)
    ) DEFAULT CHARSET=utf8;"
    _connect.execute(_create_query)
    return
  end
end
