# -*- encoding: utf-8 -*-
class Gwsub::Sb04CheckSection < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to  :fy_rel     ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'
  has_many    :staffs     ,:foreign_key=>:section_id    ,:class_name=>'Gwsub::Sb04CheckStafflist' , :order=>'kana'

  validates_presence_of :code
  validates_presence_of :name
  validates_presence_of :ldap_code

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

    if !self.ldap_code.blank? && self.ldap_code.size ==5
      self.ldap_code = self.ldap_code.to_s+'0'
    end

    group = nil
    unless self.ldap_code.blank?
      g_cond  = "state='enabled' and code='#{self.ldap_code}'"
      g_order = "end_at is null , start_at DESC"
      group = System::GroupHistory.find(:first,:conditions=>g_cond,:order=>g_order)
    end

    if group.blank?
      self.ldap_name  = nil
    else
      self.ldap_name  = group.name
    end
  end

  def self.sb04_group_select(all = nil,options={})
    selects = []

    g_order = "code, id"
    items = self.find(:all,:order=>g_order)

    return selects << ['所属未設定','0'] if items.blank?

    selects << ['すべて' , '0'] if all.to_s.blank?
    items.each do |g|
      selects << [g.name ,g.id]
    end
    return selects
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:code,:name,:remarks
      when 'grped_id'
        search_id v,:id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
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
              if _csv.length <= 5
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
                  if code_dup_check.index(_csv[1].to_s) # コードの重複チェック
                    error_msg_row << "所属コードが重複しています。"
                  else
                    code_dup_check << _csv[1].to_s
                  end
                end

                if _csv[2].blank? # 所属
                  error_msg_row << "所属が空となっています。"
                end

                if _csv[4].blank? # 所属コード（システム）
                  # 空欄の場合、チェックせずに進める。
                else
                  if _csv[4].to_s !~  /^[0-9A-Za-z\_]+$/
                    error_msg_row << "所属コード（システム）に半角英数字およびアンダーバー（_）以外の文字が存在します。"
                  else
                    if self.check_ldap_code(_csv[4]).blank?
                      error_msg_row << "所属コード（システム）を持つ所属が存在しません。"
                    end
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
                if error_csv_row.length < 5 # エラー出力の場所を調整するため、配列の要素数が足らない場合はnilで要素を埋める
                  error_csv_row = Gw.a_in_nil(error_csv_row, 5)
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
        item.code         = row[1]
        item.name         = row[2]
        item.remarks      = row[3]
        item.ldap_code    = row[4]
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

  def self.check_ldap_code(ldap_code = nil)
    # ldap_codeが存在するかどうかのチェック。所属名が返れば存在するとする。
    return nil if ldap_code.blank?

    g_cond  = "state='enabled' and code='#{ldap_code}'"
    g_order = "end_at is null , start_at DESC"
    group = System::GroupHistory.find(:first,:conditions=>g_cond,:order=>g_order)
    if group.blank?
      ldap_name  = nil
    else
      ldap_name  = group.name
    end
    return ldap_name
  end

  def self.check_section_code(section_code = nil)
    # codeが存在するかどうかのチェック。コードが返れば存在するとする。
    return nil if section_code.blank?

    cond  = "code='#{section_code}'"
    order = "id"
    item = Gwsub::Sb04CheckSection.find(:first, :conditions=>cond, :order=>order)
    if item.blank?
      ldap_name  = nil
    else
      ldap_name  = item.code
    end
    return ldap_name
  end

  def self.check_fyear_id(fyear_id = nil)
    # 指定fyear_idと、違うデータがないかどうかチェックする。
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
    # auto_incrementを設定。truncate_tableの後に実行。
    id = Gwsub::Sb04section.maximum(:id)
    id = nz(id, 0) + 1
    connect = self.connection()
    truncate_query = "ALTER TABLE `#{self.table_name}` AUTO_INCREMENT=#{id}"
    connect.execute(truncate_query)
  end

  def self.import_table(fyear_id = nil)
    Gwsub::Sb04section.destroy_all(:fyear_id=>fyear_id)
    fields = Array.new
    items = self.find(:all, :order => 'id')

    self.columns.each do |column|
      fields << "#{column.name}"
    end

    items.each do |item|
      model = Gwsub::Sb04section.new
      model.class.before_save.clear # コールバックをフックして無効化する。
      fields.each do |field|
        eval("model.#{field} = nz(item.#{field}, nil)")
      end
      model.save(:validate=>false)
    end
  end
end
