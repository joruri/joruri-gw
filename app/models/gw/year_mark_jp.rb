# encoding: utf-8
class Gw::YearMarkJp < Gw::Database
  include System::Model::Base
  include Cms::Model::Base::Content

  before_validation :mark_upcase
  validates_presence_of :name,:mark,:start_at
  validates_uniqueness_of :name,:mark,:start_at

  #記号の半角英数字チェック
  validates_each :mark do |record, attr, value|
    unless value.blank?
      record.errors.add attr, 'は、半角英数字で入力してください。' unless value.to_s =~ /^[0-9A-Za-z]+$/
    end
  end

  # 登録済日付より過去日付をエラーとする対応。
  validates_each :start_at do |record, attr, value|
    unless value.blank?
      cond = "start_at > '#{value.strftime("%Y-%m-%d 00:00:00")}'"
      if record.new_record?
      #  #新規作成の場合、単純に過去日付に割り込まないかチェック
        cnt =  Gw::YearMarkJp.count(:all , :order=>"start_at DESC" , :conditions=>cond)
        record.errors.add attr, 'は、過去日付に割り込むため、登録できません。' if cnt != 0
      else
      #  #編集の場合、自分のレコードを除外
        cond += " AND id <> #{record.id}"
        cnt =  Gw::YearMarkJp.count(:all , :order=>"start_at DESC" , :conditions=>cond)
        record.errors.add attr, 'は、過去日付に割り込むため、登録できません。' if cnt != 0
      end
    end
  end

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'_admin', 'developer')
  end
  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'_admin', 'admin')
  end

  def mark_upcase
    self.mark = self.mark.to_s.upcase
  end

  def self.get_mark(start_at)
    data = self.get_record(start_at)
    return data.mark
  end
  def self.get_name(start_at)
    data = self.get_record(start_at)
    return data.name
  end
  def self.get_record(start_at)
    pd = self.date_check(start_at)
    order = "start_at DESC"
#    cond = "start_at < '#{start_at}'"
    cond = "start_at <= '#{pd[0]}-#{pd[1]}-#{pd[2]} 00:00:00'"
    item = Gw::YearMarkJp.find(:first,:conditions=>cond,:order=>order)
    return item
  end
  def self.get_old_year_mark_record(start_at)
    #年度の始まりが1~3月の場合の対応  1年前の年号を取得する
    pd = self.date_check(start_at)
    old_year = pd[0].to_i - 1
    order = "start_at DESC"
#    cond = "start_at < '#{start_at}'"
    cond = "start_at <= '#{old_year}-#{pd[1]}-#{pd[2]} 00:00:00'"
    item = Gw::YearMarkJp.find(:first,:conditions=>cond,:order=>order)
    return item
  end
  def self.date_check(fyear_start_at)
#pp fyear_start_at,fyear_start_at.class
    pd=[]
    begin
      if fyear_start_at.is_a?(Date)
        pd[0] = sprintf("%4d", fyear_start_at.year)
        pd[1] = sprintf("%02d", fyear_start_at.mon)
        pd[2] = sprintf("%02d", fyear_start_at.mday)
      else
        if fyear_start_at.is_a?(Time)
          pd[0] = sprintf("%4d", fyear_start_at.year)
          pd[1] = sprintf("%02d", fyear_start_at.mon)
          pd[2] = sprintf("%02d", fyear_start_at.mday)
        else
          if fyear_start_at.is_a?(String)
            # yyyy-mm-dd HH:MM:SS を分割
            pd0 = fyear_start_at.split(' ')
            pd = pd0[0].split('-')
#pp pd0,pd
            return [0,0,0,0,0,0] if pd.size < 3
  #          pd = Date.parse("#{fyear_start_at}",true)
            pd[0] = sprintf("%4d", pd[0])
            if pd[1].to_s.length == 1
              pd[1] = sprintf("%02d",pd[1])
            end
            if pd[2].to_s.length == 1
              pd[2] = sprintf("%02d",pd[2])
            end
          end
        end
      end
    rescue
      raise TypeError, "cannot recognize datetime format(#{fyear_start_at})"
    end
    return pd

  end

  def self.convert_ytoj(start_at,pattern = nil,skip = '0')
    # patern:'1' 西暦年度(fyear)/'2'記号年度(markjp)/'3'和暦年度(namejp)/'4'すべての年度種類
    # 西暦年を年度に変換(4月1日基準)
    # skip: '1'1~3月のとき開始年を一年マイナスしない（和暦年変換）/ '0'1~3月のとき開始年を一年マイナスする（年度変換）
    # 戻り値は配列
    # 入力チェック
#    pp ['mark',start_at,pattern]
    start_ymd = self.date_check(start_at)
    base = self.get_record(start_at)
    return nil unless base
    base_ymd = self.date_check(base.start_at)
#pp ['base',base]
#pp ['base_ymd',base_ymd]
    if skip == '0'
      # １－３月は、年から１を引き、西暦年度とする
      case start_ymd[1]
      when '01','02','03'
        start_year = start_ymd[0].to_i - 1
      else
        start_year = start_ymd[0].to_i
      end
    else
      start_year = start_ymd[0].to_i
    end
    # base年から和暦年を計算
    # TODO s.mokubo 年月日と年号開始日の比較
    fyear_jp = start_year - base_ymd[0].to_i + 1
    if (fyear_jp == 0 && skip == '0')
      base = self.get_old_year_mark_record(start_at)
      base_ymd = self.date_check(base.start_at)
      fyear_jp = start_year - base_ymd[0].to_i + 1
    end

    fyear_jp = '元' if fyear_jp == 1
    start_markjp = base.mark + fyear_jp.to_s
    start_namejp = base.name + fyear_jp.to_s
#pp [start_year,start_markjp,start_namejp]
    case pattern
    when '1'
      return [start_year,'0','0']
    when '2'
      return ['0',start_markjp,'0']
    when '3'
      return ['0','0',start_namejp]
    when '4'
      return [start_year,start_markjp,start_namejp]
    else
      return ['0','0','0']
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :name,:mark,:start_at
      end
    end if params.size != 0

    return self
  end
  def self.drop_create_table
    _connect = self.connection()
    _drop_query = "DROP TABLE `gw_year_mark_jps` ;"
    _connect.execute(_drop_query)
    _create_query = "CREATE TABLE `gw_year_mark_jps` (
      `id`            int(11)  NOT NULL auto_increment,
      `name`          text     default NULL,
      `mark`          text     default NULL,
      `start_at`      datetime default NULL,
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
  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gw_year_mark_jps` ;"
    connect.execute(truncate_query)
  end

  def creatable?
    return true
  end
  def editable?
    return true
  end
  def deletable?
    return true
  end
end
