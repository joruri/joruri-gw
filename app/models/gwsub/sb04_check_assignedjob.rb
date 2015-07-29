# -*- encoding: utf-8 -*-
class Gwsub::Sb04CheckAssignedjob < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fy_rel     ,:foreign_key=>:fyear_id           ,:class_name=>'Gw::YearFiscalJp'
  belongs_to :section    ,:foreign_key=>:section_id         ,:class_name=>'Gwsub::Sb04CheckSection'
  has_many   :staffs     ,:foreign_key=>:assignedjobs_id    ,:class_name=>'Gwsub::Sb04CheckStafflist'

  validates_presence_of :section_id
  validates_presence_of :code

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save   :before_save_setting_columns

  def before_save_setting_columns
    if self.fyear_id.to_i==0
      if self.fyear_markjp.blank?
      else
        order = "start_at DESC"
        conditions = "markjp = '#{self.fyear_markjp}'"
        fyear = Gw::YearFiscalJp.find(:first,:conditions=>conditions,:order=>order)
        self.fyear_id = fyear.id
      end
    else
      self.fyear_markjp = self.fy_rel.markjp
    end
    if self.section_id.to_i == 0
      if self.section_code.blank?
      else
        order = "code"
        conditions = "fyear_markjp = '#{self.fyear_markjp}' and code = '#{self.section_code}'"
        section = Gwsub::Sb04CheckSection.find(:first,:conditions=>conditions,:order=>order)
        if section.blank?
          self.section_id = 0
        else
          self.section_id = section.id
        end
      end
    else
      self.section_code = self.section.code
      self.section_name = self.section.name
    end
    self.code_int     = self.code.to_i
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
        search_keyword v,:code,:name,:remarks,:section_name,:tel
      when 'grped_id'
        search_id v,:section_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.csv_check(params)
    
    error_msg = Array.new
    check = Hash::new
    check_ldap_code = Hash::new # コード重複チェック（所属コードと連携するため、他のCSV追加と違ってハッシュとなっていることに注意）
    import_csv = Array.new # インポートデータ
    error_csv  = Array.new # エラー発生データ
    error_row_cnt = 0      # エラー行数カウント
    require 'csv'

    par_item = params[:item]
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
              if _csv.length <= 8
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

                if _csv[2].blank? # 所属
                  error_msg_row << "所属が空となっています。"
                end

                if _csv[3].blank? # 担当コード
                  error_msg_row << "担当コードが空となっています。"
                else
                  if _csv[3].to_s !~  /^[0-9A-Za-z]+$/
                    error_msg_row << "担当コードに半角英数字以外の文字が存在します。"
                  end
                  if check_ldap_code.key?(_csv[1].to_s) # コード重複チェック
                    if check_ldap_code[_csv[1].to_s].index(_csv[3].to_s)
                      error_msg_row << "担当コードが重複しています。"
                    else
                      check_ldap_code[_csv[1].to_s] << _csv[3].to_s
                    end
                  else
                    check_ldap_code[_csv[1].to_s] = Array.new
                    check_ldap_code[_csv[1].to_s] << _csv[3].to_s
                  end
                end

              else
                error_msg_row << 'CSVの列数が不正です。'
              end

              # エラーメッセージ
              if error_msg_row.empty?
                import_csv << _csv
              else
                error_row_cnt += 1
                if error_csv_row.length < 8 # エラー出力の場所を調整するため、配列の要素数が足らない場合はnilで要素を埋める
                  error_csv_row = Gw.a_in_nil(error_csv_row, 8)
                end
                error_csv_row << Gw.join(error_msg_row, '')
                error_msg += error_msg_row
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
        item.fyear_markjp = row[0]
        item.section_code = row[1]
        item.section_name = row[2]
        item.code         = row[3]
        item.name         = row[4] unless row[4].blank?
        item.tel          = row[5] unless row[5].blank?
        item.address      = row[6] unless row[6].blank?
        item.remarks      = row[7] unless row[7].blank?
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
    items = self.find(:all)
    items.each do |item|
      return false if item.fyear_id.to_i != fyear_id.to_i #違うデータがあればfalse
    end
    return true
  end
  
  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `#{self.table_name}` ;"
    connect.execute(truncate_query)
  end

  def self.set_autoincrement_number
    id = Gwsub::Sb04assignedjob.maximum(:id)
    id = nz(id, 0) + 1
    connect = self.connection()
    truncate_query = "ALTER TABLE `#{self.table_name}` AUTO_INCREMENT=#{id}"
    connect.execute(truncate_query)
  end

  def self.import_table(fyear_id = nil)
    Gwsub::Sb04assignedjob.destroy_all(:fyear_id=>fyear_id)
    fields = Array.new
    items = self.find(:all, :order => 'id')

    self.columns.each do |column|
      fields << "#{column.name}"
    end

    items.each do |item|
      model = Gwsub::Sb04assignedjob.new
      model.class.before_save.clear # コールバックをフックして無効化する。
      fields.each do |field|
        eval("model.#{field} = nz(item.#{field}, nil)")
      end
      model.save(:validate=>false)
    end
  end
end
