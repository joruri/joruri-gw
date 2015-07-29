# -*- encoding: utf-8 -*-
class Gwsub::Sb04CheckStafflist < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to  :fy_rel     ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'

  belongs_to :section    ,:foreign_key=>:section_id        ,:class_name=>'Gwsub::Sb04CheckSection'
  belongs_to :job        ,:foreign_key=>:assignedjobs_id   ,:class_name=>'Gwsub::Sb04CheckAssignedjob'
  belongs_to :official   ,:foreign_key=>:official_title_id ,:class_name=>'Gwsub::Sb04CheckOfficialtitle'

  validates_presence_of :section_id
  validates_presence_of :staff_no
  validates_presence_of :name
  # 兼務登録は、同一担当では不可
  validates_uniqueness_of :staff_no ,:scope=>[:fyear_id,:section_id,:assignedjobs_id] ,:message=>"は担当で登録済です。"

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def before_save_setting_columns
    if self.fyear_id.to_i==0
      before_save_setting_id
    else
      self.fyear_markjp               = self.fy_rel.markjp
      unless self.section_id.to_i==0
        self.section_code             = self.section.code
        self.section_name             = self.section.name
      else
        self.section_code             = nil
        self.section_name             = nil
      end
      unless self.assignedjobs_id.to_i==0
        self.assignedjobs_code        = self.job.code
        self.assignedjobs_code_int    = self.job.code.to_i
        self.assignedjobs_name        = self.job.name
        self.assignedjobs_tel         = self.job.tel
        self.assignedjobs_address     = self.job.address
      else
        self.assignedjobs_code        = nil
        self.assignedjobs_code_int    = nil
        self.assignedjobs_name        = nil
        self.assignedjobs_tel         = nil
        self.assignedjobs_address     = nil
      end
      unless self.official_title_id.to_i==0
        self.official_title_code_int  = self.official.code.to_i
        self.official_title_code      = self.official.code
        self.official_title_name      = self.official.name
      else
        self.official_title_code_int  = nil
        self.official_title_code      = nil
        self.official_title_name      = nil
      end
      self.categories_code          = nil
      self.categories_name          = nil
      self.divide_duties_order_int    = self.divide_duties_order.to_i   unless self.divide_duties_order.blank?
    end
  end
  def before_save_setting_id
    if self.fyear_markjp.blank?
      if self.fyear_id.blank?
        self.fyear_id = 0
      end
    else
      order = "start_at DESC"
      conditions = "markjp = '#{self.fyear_markjp}'"
      fyear = Gw::YearFiscalJp.find(:first,:conditions=>conditions,:order=>order)
      self.fyear_id = fyear.id
    end

    if self.section_code.blank?
      if self.section_id.blank?
        self.section_id = 0
      end
    else
      section = Gwsub::Sb04CheckSection.new
      section.fyear_id = self.fyear_id
      section.code = self.section_code
      section.order "fyear_markjp DESC , code ASC"
      sections = section.find(:all)
      self.section_id = sections[0].id unless sections.blank?
    end
    if self.assignedjobs_code.blank?
      if self.assignedjobs_id.blank?
        job = Gwsub::Sb04CheckAssignedjob.new
        job.fyear_id  = self.fyear_id
        job.section_id  = self.section_id
        job.order "code_int"
        jobs = job.find(:first)
        unless jobs.blank?
          self.assignedjobs_id        = jobs.id
          self.assignedjobs_code      = jobs.code
          self.assignedjobs_code_int  = jobs.code.to_i
          self.assignedjobs_name      = jobs.name
          self.assignedjobs_tel       = jobs.tel
          self.assignedjobs_address   = jobs.address
        end
      end
    else
      assignedjob   = Gwsub::Sb04CheckAssignedjob.new
      assignedjob.fyear_id = self.fyear_id
      assignedjob.code = self.assignedjobs_code
      assignedjob.order "fyear_markjp DESC , code ASC"
      assignedjobs  = assignedjob.find(:all)
      self.assignedjobs_id = assignedjobs[0].id unless assignedjobs.blank?
    end
    if self.official_title_code.blank?
      if self.official_title_id.blank?
        self.official_title_id = 0
      end
    else
      official_title = Gwsub::Sb04CheckOfficialtitle.new
      official_title.fyear_id = self.fyear_id
      official_title.code     = self.official_title_code
      official_title.order "fyear_markjp DESC , code ASC"
      official_titles = official_title.find(:all)
      self.official_title_id = official_titles[0].id unless official_titles.blank?
    end
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
        # 所属・担当・職名・氏名・内線・備考・フリガナ・職員番号・事務分掌
        and_keywords2 v,:section_name,:assignedjobs_name,:official_title_name,:name,:extension,:remarks,:kana,:staff_no,:divide_duties
      when 'grped_id'
        search_id v,:section_id unless v.to_i == 0
      end
    end if params.size != 0

    return self
  end

  def self.csv_check(params)
    error_msg = Array.new
    check = Hash::new
    code_dup_check = Array.new # コード重複チェック
    import_csv = Array.new # インポートデータ
    error_csv  = Array.new # エラー発生データ
    error_row_cnt = 0      # エラー行数カウント
    require 'csv'

    par_item = params[:item]
#      raise ArgumentError, '入力指定が異常です。' if par_item.nil? || par_item[:nkf].nil? || par_item[par_item[:nkf]].nil?
    if par_item.nil? || par_item[:nkf].nil? || par_item[:file].nil?
      error_msg << 'ファイル名を入力してください'
    else

      upload_data = par_item[:file]
      filename =  upload_data.original_filename
      extname = File.extname(filename)
      # 拡張子が異なる場合、エラーを返す。
      if extname != '.csv'
        error_msg << '拡張子がCSV形式のものと異なります。拡張子が「csv」のファイルを指定してください。'
      else
        f = upload_data.read
        nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w -W'
        when 'sjis'
          '-w -S'
        end
        file =  NKF::nkf(nkf_options,f)
        if file.blank?
        else
          csv = CSV.parse(file)

          year_fiscal = Gw::YearFiscalJp.find_by_id(par_item[:fyed_id])
          csv.each_with_index do |row, i|
            error_msg_row = Array.new
            error_csv_row = row.dup

            if i == 0  # 最初の1行はフィールド名なので無視する。
              error_csv_row << 'error'
            elsif row.empty? # 改行のみの行は空の配列となるので、それも無視する。
            else

              _csv = row.dup # CSVデータの変更用配列
              if _csv.length <= 11
                if _csv[0].blank? # 年度
                  error_msg_row << "年度が空です。"
                elsif year_fiscal.markjp != "#{_csv[0]}"
                  error_msg_row << "年度が不正です。"
                end

                if _csv[1].blank? # 所属コード
                  error_msg_row << "所属コードが空となっています。"
                elsif _csv[1].to_s !~  /^[0-9A-Za-z\_]+$/
                  error_msg_row << "所属コードに半角英数字およびアンダーバー（_）以外の文字が存在します。"
                else
                  if Gwsub::Sb04CheckSection.check_section_code(_csv[1]).blank?
                    error_msg_row << "所属コードが、20所属のデータに存在しません。"
                  end
                end

                if _csv[2].blank? # 所属名
                  error_msg_row << "所属名が空です。"
                end

                if _csv[3].blank? # 所属コード
                  error_msg_row << "職員番号が空となっています。"
                elsif _csv[3].to_s !~  /^[0-9A-Za-z\_]+$/
                  error_msg_row << "職員番号に半角英数字およびアンダーバー（_）以外の文字が存在します。"
                else
                  if !_csv[7].blank? && _csv[7].to_i == 1 # コードの重複チェック。本務のみチェックする。
                    if code_dup_check.index(_csv[3].to_s)
                      error_msg_row << "職員番号が重複しています。"
                    else
                      code_dup_check << _csv[3].to_s
                    end
                  end
                end

                if _csv[5].blank? # 氏名（変換後）
                  error_msg_row << "氏名（変換後）が空です。"
                end

                if _csv[7].blank? # 兼務フラグ
                  error_msg_row << "兼務フラグが空です。"
                elsif _csv[7].to_i != 1 && _csv[7].to_i != 2
                  error_msg_row << "兼務フラグが異常です。兼務フラグは、1、もしくは2で指定してください。"
                end
                if _csv[8].blank? # 職員録表示フラグ
                  error_msg_row << "職員録表示フラグが空です。"
                elsif _csv[8].to_i != 1 && _csv[8].to_i != 2
                  error_msg_row << "職員録表示フラグが異常です。職員録表示フラグは、1、もしくは2で指定してください。"
                end
                if _csv[9].blank? # 事務分掌表示フラグ
                  error_msg_row << "事務分掌表示フラグが空です。"
                elsif _csv[9].to_i != 1 && _csv[9].to_i != 2
                  error_msg_row << "事務分掌表示フラグが異常です。事務分掌表示フラグは、1、もしくは2で指定してください。"
                end
              else
                error_msg_row << 'CSVの列数が不正です。'
              end

              # エラーメッセージ
              if error_msg_row.empty?
                import_csv << _csv
              else
                error_row_cnt += 1
                if error_csv_row.length < 11 # エラー出力の場所を調整するため、配列の要素数が足らない場合はnilで要素を埋める
                  error_csv_row = Gw.a_in_nil(error_csv_row, 11)
                end
                error_csv_row << Gw.join(error_msg_row, '')
                error_msg << error_msg_row
              end
            end
            error_csv << error_csv_row # エラー時に出力するCSV生成
          end # CSV do end
        end
      end
    end

    if error_msg.empty? # エラー無し
      check[:result] = true
      check[:error_msg] = nil

      self.truncate_table # テーブルを空にする。
      self.set_autoincrement_number
      import_csv.each do |row| # データインポート
        item = self.new
        item.fyear_markjp        = row[0]
        item.section_code        = row[1]
        item.section_name        = row[2]
        item.staff_no            = row[3]
        item.name                = row[5]
        item.name_print          = row[4]
        item.kana                = row[6]
        item.multi_section_flg   = row[7]
        item.personal_state      = row[8]
        item.display_state       = row[9]
        item.save(:validate=>false)
      end
    else  # エラーあり
      check[:result] = false
      if error_row_cnt == 0
        check[:error_msg] = Gw.join(error_msg, '<br />')
        check[:error_kind] = 'error'
      else
        check[:error_msg] = "#{error_row_cnt}行、エラーが存在します。"
        check[:error_kind] = 'csv_error'
        check[:csv_data] = error_csv
      end
    end
    return check
  end

  def self.check_fyear_id(fyear_id = nil)
    # 指定fyear_idと、違うデータがないかどうかチェックする。
    items = self.find(:all)
    items.each do |item|
      return false if item.fyear_id.to_i != fyear_id.to_i #違うデータがあればfalse
    end
    return true
  end

  def self.check_fyear_id_all(fyear_id = nil)
    # 指定fyear_idと、違うデータがないかどうかチェックする。すべてのデータをチェックする。
    msg = Array.new
    _msg = 'のデータに、指定とは異なる年度が含まれています。'
    _msg_count = 'のデータは登録されていません。'
    check = Hash::new

    check_1_count = Gwsub::Sb04CheckOfficialtitle.count(:id)
    if check_1_count > 0
      check_1 = Gwsub::Sb04CheckOfficialtitle.check_fyear_id(fyear_id)
      if check_1 != true
        msg << '職名' + _msg
      end
    else
      check_1 = false
      msg << '職名' + _msg_count
    end

    check_2 = true
    check_3_count = Gwsub::Sb04CheckSection.count(:id)
    if check_3_count > 0
      check_3 = Gwsub::Sb04CheckSection.check_fyear_id(fyear_id)
      if check_3 != true
        msg << '所属' + _msg
      end
    else
      check_3 = false
      msg << '所属' + _msg_count
    end

    check_4_count = Gwsub::Sb04CheckAssignedjob.count(:id)
    if check_4_count > 0
      check_4 = Gwsub::Sb04CheckAssignedjob.check_fyear_id(fyear_id)
      if check_4 != true
        msg << '担当' + _msg
      end
    else
      check_4 = false
      msg << '担当' + _msg_count
    end

    check_5_count = Gwsub::Sb04CheckStafflist.count(:id)
    if check_5_count > 0
      check_5 = Gwsub::Sb04CheckStafflist.check_fyear_id(fyear_id)
      if check_5 != true
        msg << '職員' + _msg
      end
    else
      check_5 = false
      msg << '職員' + _msg_count
    end

    check[:flg] = check_1 && check_2 && check_3 && check_4 && check_5
    if check[:flg] == true
      check[:msg] = ''
    else
      check[:msg] = Gw.join(msg, '<br />')
    end
    return check
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `#{self.table_name}` ;"
    connect.execute(truncate_query)
  end

  def self.set_autoincrement_number
    # auto_incrementを設定。truncate_tableの後に実行。
    id = Gwsub::Sb04stafflist.maximum(:id)
    id = nz(id, 0) + 1
    connect = self.connection()
    truncate_query = "ALTER TABLE `#{self.table_name}` AUTO_INCREMENT=#{id}"
    connect.execute(truncate_query)
  end

  def self.import_table(fyear_id = nil)
    Gwsub::Sb04stafflist.destroy_all(:fyear_id=>fyear_id)
    fields = Array.new
    items = self.find(:all, :order => 'id')

    self.columns.each do |column|
      fields << "#{column.name}"
    end

    items.each do |item|
      model = Gwsub::Sb04stafflist.new
      model.class.before_save.clear # コールバックをフックして無効化する。
      fields.each do |field|
        eval("model.#{field} = nz(item.#{field}, nil)")
      end
      model.save(:validate=>false)
    end
  end
end
