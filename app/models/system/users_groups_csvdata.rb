# encoding: utf-8
class System::UsersGroupsCsvdata < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Base::Content
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'System::UsersGroupsCsvdata'
  has_many :children, :foreign_key => :parent_id, :class_name => 'System::UsersGroupsCsvdata',
    :order => 'code, sort_no, id'
  has_many :groups, :foreign_key => :parent_id, :class_name => 'System::UsersGroupsCsvdata',
    :conditions => {:data_type => 'group'}, :order => 'code, sort_no, id'
  has_many :users, :foreign_key => :parent_id, :class_name => 'System::UsersGroupsCsvdata',
    :conditions => {:data_type => 'user'}, :order => 'code, sort_no, id'

  def self.csvget
    csv = Array.new

    csv << csv_header.values
    @groups = System::Group.get_level2_groups

    @groups.each do |group|
      csv << group.csvget_data
      group.children.each do |c_group|
        csv << c_group.csvget_data
        c_group.users.each do |user|
          csv_row = Array.new
          user_group = System::UsersGroup.find(:first, :conditions=>["user_id = ? and group_id = ?", user.id, c_group.id])
          csv_row << System::UsersGroup.state_show(user.state)
          csv_row << "user"
          csv_row << ""
          csv_row << c_group.code
          csv_row << user.code
          csv_row << System::UsersGroup.ldap_show(user.ldap)
          csv_row << System::UsersGroup.job_order_show(user_group.job_order)
          csv_row << user.name
          csv_row << user.name_en
          csv_row << user.kana
          csv_row << user.password
          csv_row << System::User.mobile_access_show(user.mobile_access)
          csv_row << user.mobile_password
          csv_row << user.email
          csv_row << user.official_position
          csv_row << user.assigned_job
          csv_row << Gw.date_str(user_group.start_at)
          csv_row << Gw.date_str(user_group.end_at)
          csv << csv_row
        end
      end
    end
    
    return csv
  end


  def self.csvup(params)
    error_msg = Array.new
    check = Hash::new
    error_row_cnt = 0
    require 'csv'

    ldap_states = Gw.yaml_to_array_for_select('system_users_ldaps')
    ldap_states_0 = ldap_states.map {|x| x[0]}
    states = Gw.yaml_to_array_for_select('system_states')
    states_0 = states.map {|x| x[0]}
    job_order_states = Gw.yaml_to_array_for_select('system_ugs_job_orders')
    job_order_states_0 = job_order_states.map {|x| x[0]}
    mobile_access_states = Gw.yaml_to_array_for_select('t1f0_kyoka_fuka')
    mobile_access_states_0 = mobile_access_states.map {|x| x[0]}

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
        file =  NKF::nkf(nkf_options, f)

        if file.blank?
        else
          csv = CSV.parse(file)
          csv_hashed = Array.new # ハッシュ変換用
          error_csv_row = csv.dup # エラー返却用CSVデータ
          hankaku_error_string = "半角英数字、および半角アンダーバーのみのデータとしてください。"
          
          code_data = Array.new # コードの値をまとめる配列
          groups_code_data = Array.new # グループのコードの値をまとめる配列
          users_code_pcode_data = Array.new # ユーザーのコード、親グループコードの値をまとめる配列
          users_code_honmu_data = Array.new # 「本務・兼務」本務の時の、ユーザーのコードをまとめる配列
          keys = csv_header.keys

          admin_user_check = false
          csv.each_with_index do |row, i| # 配列をハッシュに変換。また、チェック用のデータを作成する。
            if i == 0  # 最初の1行はフィールド名なので無視する。
              error_csv_row[i] << 'error'
              next
            elsif row.empty? # 改行のみの行は空の配列となるので、それも無視する。
              next
            end

            hashed_row = Hash[*keys.zip(row).flatten]
            hashed_row[:id] = i
            hashed_row[:start_time] = nil
            hashed_row[:end_time] = nil
            hashed_row[:error] = ""

            csv_hashed << hashed_row # ハッシュに変換したデータを格納
            code_data << hashed_row[:code]
            if hashed_row[:data_type] == "group"
              groups_code_data << hashed_row[:code]
            elsif hashed_row[:data_type] == "user"
              users_code_pcode_data << [hashed_row[:parent_code], hashed_row[:code]]
              if hashed_row[:job_order] == "本務"
                users_code_honmu_data << hashed_row[:parent_code]
              end
            end

            # 管理権限チェック
            if hashed_row[:data_type] == "user" && hashed_row[:state] == "有効"
              user = System::User.find(:first, :conditions => ["code = ?",hashed_row[:code] ])
              if user.present? && System::User.is_admin?(user.id)
                admin_user_check = true
              end
            end

          end
          uniq_groups_code_data = Gw.get_uniq_data(groups_code_data) # 重複したコード
          uniq_users_code_pcode_data = Gw.get_uniq_data(users_code_pcode_data) # 重複したコード
          uniq_users_code_honmu_data = Gw.get_uniq_data(users_code_honmu_data) # 重複したコード

          csv_hashed.each do |row|
            # 状態
            if row[:state].blank?
              row[:error] << "「#{csv_header[:state]}」は必須です。"
            elsif states_0.index(row[:state]).blank?
              row[:error] << "「#{csv_header[:state]}」に、「#{Gw.join(states_0, "・")}」以外のデータが入っています。"
            end

            # 種別
            if row[:data_type].blank?
              row[:error] << "「#{csv_header[:data_type]}」は必須です。"
            elsif ["group", "user"].index(row[:data_type]).blank?
              row[:error] << "「#{csv_header[:data_type]}」に、「group・user」以外のデータが入っています。"
            end

            # 階層
            if row[:data_type] == "group"
              if row[:level].blank?
                row[:error] << "「#{csv_header[:level]}」は必須です。"
              elsif ["部局", "所属"].index(row[:level]).blank?
                row[:error] << "「#{csv_header[:level]}」に、「部局・所属」以外のデータが入っています。"
              end
            end

            # 親グループコード
            if row[:parent_code].blank?
              row[:error] << "「#{csv_header[:parent_code]}」は必須です。"
            elsif Gw.half_width_characters?(row[:parent_code]) != true
              row[:error] << "「#{csv_header[:parent_code]}」は、#{hankaku_error_string}"
            elsif row[:data_type] == "group" && row[:level] == "部局" && row[:parent_code] != "1"
              row[:error] << "「#{csv_header[:level]}」が部局の時、、「#{csv_header[:parent_code]}」は1としてください。"
            elsif row[:data_type] == "group" && row[:level] == "所属" && code_data.index(row[:parent_code]).blank?
              row[:error] << "「#{csv_header[:level]}」が所属の時、、「#{csv_header[:parent_code]}」は「#{csv_header[:code]}」に存在するデータとしてください。"
            elsif row[:data_type] == "user" && code_data.index(row[:parent_code]).blank?
              row[:error] << "「#{csv_header[:data_type]}」がuserの時、、「#{csv_header[:parent_code]}」は「#{csv_header[:code]}」に存在するデータとしてください。"
            end

            # コード
            if row[:code].blank?
              row[:error] << "「#{csv_header[:code]}」は必須です。"
            elsif System::User.valid_user_code_characters?(row[:code]) != true
              row[:error] << "「#{csv_header[:code]}」は、#{hankaku_error_string}"
            else
              if row[:data_type] == "group" # グループ
                if uniq_groups_code_data.index(row[:code]).present?
                  row[:error] << "「#{csv_header[:data_type]}」がgroupのデータは、「#{csv_header[:code]}」が重複してはなりません。"
                end
                if row[:code] == '1'
                  row[:error] << "「#{csv_header[:code]}」に「1」は使用できません。"
                end
              end
              if admin_user_check != true
                row[:error] << "「#{csv_header[:data_type]}」がuserのデータは、「#{csv_header[:code]}」に、1つ以上、GW管理画面の管理者権限を持つユーザーが含まれてはなりません。"
                admin_user_check = true # 最初の1件のみに追加する。
              end
              if row[:data_type] == "user" # ユーザー
                if uniq_users_code_pcode_data.index( [row[:parent_code], row[:code]] ).present?
                  row[:error] << "「#{csv_header[:data_type]}」がuserのデータは、1つの「#{csv_header[:parent_code]}」に、複数の「#{csv_header[:code]}」が含まれてはなりません。"
                end
                if uniq_users_code_honmu_data.index(row[:code]).present?
                  row[:error] << "「#{csv_header[:data_type]}」がuserのデータは、「#{csv_header[:job_order]}」が本務のデータは、各「#{csv_header[:code]}」で1つにし、他は「兼務・仮所属」にしてください。"
                end
              end
            end

            # LDAP同期
            if row[:ldap].blank?
              row[:error] << "「#{csv_header[:ldap]}」は必須です。"
            elsif ldap_states_0.index(row[:ldap]).blank?
              row[:error] << "「#{csv_header[:ldap]}」に、「#{Gw.join(ldap_states_0, "・")}」以外のデータが入っています。"
            end

            # 本務・兼務
            if row[:data_type] == "user"
              if row[:job_order].blank?
                row[:error] << "「#{csv_header[:data_type]}」がuserの時、「#{csv_header[:job_order]}」は必須です。"
              elsif job_order_states_0.index(row[:job_order]).blank?
                row[:error] << "「#{csv_header[:job_order]}」に、「#{Gw.join(job_order_states_0, "・")}」以外のデータが入っています。"
              end
            end

            # 名前
            if row[:name].blank?
              row[:error] << "「#{csv_header[:name]}」は必須です。"
            end

            # パスワード
            if row[:data_type] == "user"
              if row[:password].blank?
                row[:error] << "「#{csv_header[:data_type]}」がuserの時、「#{csv_header[:password]}」は必須です。"
              elsif Gw.half_width_characters?(row[:code]) != true
                row[:error] << "「#{csv_header[:code]}」は、#{hankaku_error_string}"
              end
            end

            # モバイルアクセス許可
            if row[:data_type] == "user"
              if row[:mobile_access].blank?
                row[:error] << "「#{csv_header[:data_type]}」がuserの時、「#{csv_header[:mobile_access]}」は必須です。"
              elsif mobile_access_states_0.index(row[:mobile_access]).blank?
                row[:error] << "「#{csv_header[:mobile_access]}」に、「#{Gw.join(mobile_access_states_0, "・")}」以外のデータが入っています。"
              end
            end

            # モバイルパスワード
            if row[:mobile_access] == "許可"
              if row[:mobile_access].blank?
                row[:error] << "「#{csv_header[:mobile_access]}」が許可の時、「#{csv_header[:mobile_password]}」は必須です。"
              elsif Gw.half_width_characters?(row[:code]) != true
                row[:error] << "「#{csv_header[:mobile_password]}」は、#{hankaku_error_string}"
              end
            end

            # 電子メールアドレス
            if row[:email].present? && Gw.is_simplicity_valid_email_address?(row[:email]) != true
              row[:error] << "「#{csv_header[:email]}」が正常なメールアドレスではありません。"
            end

            # 開始日
            start_time = nil
            end_time = nil
            if row[:start_at].blank?
              row[:error] << "「#{csv_header[:start_at]}」は必須です。"
            else
              begin
                start_time = DateTime.parse(row[:start_at])
              rescue # 日付が異常、もしくは日付が存在しない場合
                row[:error] << "「#{csv_header[:start_at]}」に、日付以外のデータが入っています。"
              end

              if Time.local(start_time.year, start_time.month, start_time.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
                row[:error] << "「#{csv_header[:start_at]}」は当日より前のデータとしてください。"
              end
            end
            row[:start_time] = start_time

            # 終了日
            if row[:state] == "無効" && row[:end_at].blank?
              row[:error] << "「#{csv_header[:state]}」が無効の時、「#{csv_header[:end_at]}」は必須です。"
            end
            if row[:end_at].present?
              begin
                end_time = DateTime.parse(row[:end_at])
              rescue # 日付が異常、もしくは日付が存在しない場合
                row[:error] << "「#{csv_header[:end_at]}」に、日付以外のデータが入っています。"
              end

              if start_time.present? && end_time.present?
                if row[:state] == "無効" && Time.local(end_time.year, end_time.month, end_time.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
                  row[:error] << "「#{csv_header[:state]}」が無効の時、「#{csv_header[:end_at]}」は当日より前のデータとしてください。"
                elsif row[:state] == "有効"
                  row[:error] << "「#{csv_header[:state]}」が有効の時、「#{csv_header[:end_at]}」は空欄としてください。"
                end
                if end_time <= start_time
                  row[:error] << "「#{csv_header[:end_at]}」は、「#{csv_header[:start_at]}」より後のデータとしてください。"
                end
              end
            end
            row[:end_time] = end_time
            
            if row[:error].present?
              error_row_cnt += 1
              error_csv_row[row[:id]] << row[:error]
              error_msg << row[:error]
            end
          end
        end
      end
    end

    if error_msg.empty? # エラー無し
      check[:result] = true
      check[:error_msg] = nil

      self.truncate_table # テーブルを空にする。
      self.set_autoincrement_number
      csv_hashed.each do |row| # データインポート

        _state = states.assoc(row[:state])
        if _state.present?
          state = _state[1]
        else
          state = nil
        end

        _ldap_state = ldap_states.assoc(row[:ldap])
        if _ldap_state.present?
          ldap = _ldap_state[1]
        else
          ldap = nil
        end

        _job_order_state = job_order_states.assoc(row[:job_order])
        if _job_order_state.present?
          job_order_state = _job_order_state[1]
        else
          job_order_state = nil
        end

        _mobile_access_state = mobile_access_states.assoc(row[:mobile_access])
        if _mobile_access_state.present?
          mobile_access_state = _mobile_access_state[1]
        else
          mobile_access_state = nil
        end

        if row[:level] == "部局"
          level_no = 2
        elsif row[:level] == "所属"
          level_no = 3
        else
          level_no = nil
        end
        

        item = self.new
        item.state = state
        item.data_type = row[:data_type]
        item.level_no = level_no
        item.parent_id = 0
        item.parent_code = row[:parent_code]
        item.code = row[:code]
        item.ldap = ldap
        item.job_order = job_order_state
        item.name = row[:name]
        item.name_en = row[:name_en]
        item.kana = row[:kana]
        item.password = row[:password]
        item.mobile_access = mobile_access_state
        item.mobile_password = row[:mobile_password]
        item.email = row[:email]
        item.official_position = row[:official_position]
        item.assigned_job = row[:assigned_job]
        item.start_at = row[:start_time].strftime("%Y-%m-%d 0:0:0") if row[:start_time].present?
        item.end_at = row[:end_time].strftime("%Y-%m-%d 0:0:0") if row[:end_time].present?
        item.save(:validate => false)
      end
      
      all_items = self.find(:all)
      all_items.each do |item|
        if item.parent_code.to_s == "1"
          item.parent_id = 0
        else
          code_item = self.find(:first, :conditions=>["code = ?", item.parent_code])
          item.parent_id = code_item.id
        end
        item.save(:validate => false)
      end
    else  # エラーあり
      check[:result] = false
      if error_row_cnt == 0
        check[:error_msg] = Gw.join(error_msg, '<br />')
        check[:error_kind] = 'error'
      else
        check[:error_msg] = "#{error_row_cnt}行、エラーが存在します。"
        check[:error_kind] = 'csv_error'
        check[:csv_data] = error_csv_row
        check[:error_csv_filename] = "#{filename}_エラー箇所追記.csv"
      end
    end
    return check
  end

  def self.csv_header
    {
      :state => "状態",
      :data_type => "種別",
      :level => "階層",
      :parent_code => "親グループコード",
      :code => "コード",
      :ldap => "LDAP同期/非同期",
      :job_order => "本務・兼務",
      :name => "名前",
      :name_en => "名前（英字）",
      :kana => "ふりがな",
      :password => "パスワード",
      :mobile_access => "モバイルアクセス許可",
      :mobile_password => "モバイルパスワード",
      :email => "電子メールアドレス",
      :official_position => "役職",
      :assigned_job => "担当",
      :start_at => "開始日",
      :end_at => "終了日"
    }
  end

  def self.data_type_show(data_type)
    if data_type == "group"
      return "グループ"
    else
      return "ユーザー"
    end
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `#{self.table_name}` ;"
    connect.execute(truncate_query)
  end
  def self.set_autoincrement_number
    # auto_incrementを設定。truncate_tableの後に実行。
    id = self.maximum(:id)
    id = nz(id, 0) + 1
    connect = self.connection()
    truncate_query = "ALTER TABLE `#{self.table_name}` AUTO_INCREMENT=#{id}"
    connect.execute(truncate_query)
  end
end