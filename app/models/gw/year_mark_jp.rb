class Gw::YearMarkJp < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_validation :mark_upcase

  validates_presence_of :name, :mark, :start_at
  validates_uniqueness_of :name, :mark, :start_at

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
        cnt =  Gw::YearMarkJp.where(cond).order("start_at DESC").count
        record.errors.add attr, 'は、過去日付に割り込むため、登録できません。' if cnt != 0
      else
      #  #編集の場合、自分のレコードを除外
        cond += " AND id <> #{record.id}"
        cnt =  Gw::YearMarkJp.where(cond).order("start_at DESC").count
        record.errors.add attr, 'は、過去日付に割り込むため、登録できません。' if cnt != 0
      end
    end
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('_admin/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def mark_upcase
    self.mark = self.mark.to_s.upcase
  end

  def self.get_mark(start_at)
    self.get_record(start_at).try(:mark)
  end

  def self.get_name(start_at)
    self.get_record(start_at).try(:name)
  end

  def self.get_record(start_at)
    pd = self.date_check(start_at)
    order = "start_at DESC"
    cond = "start_at <= '#{pd[0]}-#{pd[1]}-#{pd[2]} 00:00:00'"
    Gw::YearMarkJp.where(cond).order(order).first
  end

  def self.get_old_year_mark_record(start_at)
    #年度の始まりが1~3月の場合の対応  1年前の年号を取得する
    pd = self.date_check(start_at)
    old_year = pd[0].to_i - 1
    order = "start_at DESC"
    cond = "start_at <= '#{old_year}-#{pd[1]}-#{pd[2]} 00:00:00'"
    item = Gw::YearMarkJp.where(cond).order(order).first
    return item
  end

  def self.date_check(fyear_start_at)
    pd=[]
    begin
      if fyear_start_at.is_a?(Date)
        pd[0] = sprintf("%4d", fyear_start_at.year)
        pd[1] = sprintf("%02d", fyear_start_at.mon)
        pd[2] = sprintf("%02d", fyear_start_at.mday)
      elsif fyear_start_at.is_a?(Time)
        pd[0] = sprintf("%4d", fyear_start_at.year)
        pd[1] = sprintf("%02d", fyear_start_at.mon)
        pd[2] = sprintf("%02d", fyear_start_at.mday)
      elsif fyear_start_at.is_a?(String)
        # yyyy-mm-dd HH:MM:SS を分割
        pd0 = fyear_start_at.split(' ')
        pd = pd0[0].split('-')

        return [0,0,0,0,0,0] if pd.size < 3
        pd[0] = sprintf("%4d", pd[0])
        if pd[1].to_s.length == 1
          pd[1] = sprintf("%02d",pd[1])
        end
        if pd[2].to_s.length == 1
          pd[2] = sprintf("%02d",pd[2])
        end
      elsif fyear_start_at.is_a?(Array)
        pd = fyear_start_at
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
    start_ymd = self.date_check(start_at)
    base = self.get_record(start_at)
    return nil unless base
    base_ymd = self.date_check(base.start_at)

    if skip == '0'
      # １−３月は、年から１を引き、西暦年度とする
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
    fyear_jp = start_year - base_ymd[0].to_i + 1
    if (fyear_jp == 0 && skip == '0')
      base = self.get_old_year_mark_record(start_at)
      base_ymd = self.date_check(base.start_at)
      fyear_jp = start_year - base_ymd[0].to_i + 1
    end

    fyear_jp = '元' if fyear_jp == 1
    start_markjp = base.mark + fyear_jp.to_s
    start_namejp = base.name + fyear_jp.to_s
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

  def creatable?
    true
  end

  def editable?
    !Gw::YearMarkJp.where("start_at > '#{start_at.strftime("%Y-%m-%d 00:00:00")}'").exists?
  end

  def deletable?
    true
  end
end
