class Gwsub::Sb05Request < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  include Gwsub::Model::Recognition

  belongs_to :m_rel    ,:foreign_key=>:media_id        ,:class_name=>'Gwsub::Sb05MediaType'
  belongs_to :user_rel ,:foreign_key=>:sb05_users_id   ,:class_name=>'Gwsub::Sb05User'

  validate :validate_start_at
  validate :validate_end_at
  validate :validate_file_size_check
  validates_presence_of :title          ,
    :unless => Proc.new{|item| !item.notes_imported.blank? }
  validates_presence_of :body1          ,
    :unless => Proc.new{|item| !item.notes_imported.blank? || (item.media_code==4 && item.categories_code==1) }
#  validates_presence_of :magazine_url   ,
#    :unless => Proc.new{|item| !item.notes_imported.blank? || item.media_code!=4 }
  validate :validate_magazine_url

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_set_items

#  after_save :save_recognizers

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('sb05/admin', '_admin/admin')
  end

  def self.is_editor?(org_code , g_code = Core.user_group.code)
#    return false if org_code.blank?
    return false unless g_code.to_s == org_code.to_s
    return true
  end

  def before_create_setting_columns
    if self.notes_imported.blank?
      Gwsub.gwsub_set_creators(self)
      Gwsub.gwsub_set_editors(self)
    end
  end
  def before_update_setting_columns
    self.notes_imported = nil
    Gwsub.gwsub_set_editors(self)
  end
  def before_save_set_items
    if self.notes_imported.blank?
      if self.sb05_users_id.to_i==0
        self.user_code    = nil
        self.user_name    = nil
        self.user_display = nil
      else
        self.user_code    = self.user_rel.user_code
        self.user_name    = self.user_rel.user_name
        self.user_display = self.user_rel.user_display
      end
    else
      self.user_display = self.user_name.to_s
    end
    if self.sb05_users_id.to_i==0
      self.org_code     = nil
      self.org_name     = nil
      self.org_display  = nil
    else
      self.org_code     = self.user_rel.org_code
      self.org_name     = self.user_rel.org_name
      self.org_display  = self.user_rel.org_display
    end
    unless self.media_id.to_i==0
      self.media_name       = self.m_rel.media_name
      self.media_code       = self.m_rel.media_code
      self.categories_name  = self.m_rel.categories_name
      self.categories_code  = self.m_rel.categories_code
    end
    set_np_body1
    set_contract_at
  end

  def set_np_body1
    # 新聞本文の編集
    # 数字は半角・整形用スペースは削除・アンダースコアをスペースに変換（全半角を維持）
    return if self.media_code != 1
    self.body1 = Gwsub.num_zen_to_han(self.body1)
    self.body1 = Gwsub.space_del(self.body1)
    self.body1 = Gwsub.rep_space(self.body1)
  end

  def set_contract_at
    #メルマガ/イベント情報の新規はedit扱いになるので、新規登録時はここはスルー。
    return if self.mm_image_state.to_s == '1'
    #編集期限の設定・期限算出の基準日も設定
    require 'date'
    st_at = self.start_at
    date = Gw.get_parsed_date(st_at)
    # 管理者による編集期限の変更を可能としたので、未設定時と希望日変更時のみ、期限を設定する
    #編集期限取得
    if self.contract_at.blank?
      # 新規作成時
      check_at = Gwsub::Sb05Request.get_contract_at(self.media_code,date,self.end_at)
      if check_at.blank?
        # 編集期限の取得に失敗したら、現在時刻
#        self.contract_at = Gw.get_parsed_date(Time.now)
#        self.base_at = Gw.get_parsed_date(Time.now)
        # 編集期限の取得に失敗したら、nil
        self.contract_at = nil
        self.base_at = nil
      else
        self.contract_at = Gw.get_parsed_date(check_at)
        base_date = Gwsub::Sb05Request.get_base_date(date , self.media_code)
        self.base_at = base_date
      end
    else
      # 編集で希望日・開始日の変更時
      if self.start_at_changed?
        check_at = Gwsub::Sb05Request.get_contract_at(self.media_code,date,self.end_at)
        if check_at.blank?
          # 編集期限の取得に失敗したら、現在時刻
#          self.contract_at = Gw.get_parsed_date(Time.now)
#          self.base_at = Gw.get_parsed_date(Time.now)
          # 編集期限の取得に失敗したら、nil
          self.contract_at = nil
          self.base_at = nil
        else
          self.contract_at = Gw.get_parsed_date(check_at)
          base_date = Gwsub::Sb05Request.get_base_date(date , self.media_code)
          self.base_at = base_date
        end
      end
    end
  end

  def self.get_contract_at(media_code,date,end_date = nil)
    # 編集期限の取得
    case media_code.to_i
    when 1
      # 新聞　掲載希望日から編集期限を取得
      d_cond = "media_code='1' and desired_at = '#{date.strftime('%Y-%m-%d 00:00:00')}'"
      d_order = "desired_at ASC"
      d_date = Gwsub::Sb05DesiredDate.where(d_cond).order(d_order).first
      if d_date.blank?
        return nil
      else
        check_at = d_date.edit_limit_at
      end
#      base_date = Gwsub::Sb05Request.get_base_date(date,1)
#      check_at = base_date - 14*24*60*60 + 18*60*60
    when 2
      # ラジオは、基準日（直前の第２・第４水曜日）から編集期限を取得
      if end_date && date
        d_cond = "media_code='2' and "
        d_cond += "( desired_at >= '#{date.strftime('%Y-%m-%d 00:00:00')}' and desired_at < '#{end_date.strftime('%Y-%m-%d 00:00:00')}' )"
        d_order = "desired_at ASC"
        d_date = Gwsub::Sb05DesiredDate.where(d_cond).order(d_order).first
        if d_date.blank?
          check_at =  nil
        else
          check_at = d_date.edit_limit_at
        end
      else
        base_date = Gwsub::Sb05Request.get_base_date(date,2)
        d_cond = "media_code='2' and desired_at = '#{base_date.strftime('%Y-%m-%d 00:00:00')}'"
        d_order = "desired_at ASC"
        d_date = Gwsub::Sb05DesiredDate.where(media_code: '2', desired_at: base_date.strftime('%Y-%m-%d 00:00:00')).order(d_order).first
        if d_date.blank?
          check_at =  nil
        else
          check_at = d_date.edit_limit_at
        end
      end

#      check_at = base_date - 14*24*60*60 + 18*60*60
    when 3
      # LEDは7日前の18時
      base_date = Gwsub::Sb05Request.get_base_date(date,3)
      check_at = base_date -  7*24*60*60 + 18*60*60
    when 4
      # メルマガ　掲載希望日から編集期限を取得
      d_cond = "media_code='4' and desired_at = '#{date.strftime('%Y-%m-%d 00:00:00')}'"
      d_order = "desired_at ASC"
      d_date = Gwsub::Sb05DesiredDate.where(media_code: '4', desired_at: date.strftime('%Y-%m-%d 00:00:00')).order(d_order).first
      if d_date.blank?
        check_at =  nil
      else
        check_at = d_date.edit_limit_at
      end
#      base_date = Gwsub::Sb05Request.get_base_date(date,4)
#      check_at = base_date -  7*24*60*60 + 15*60*60
    else     # 不明分は即時
#      check_at = date -  2*24*60*60 + 10*60*60
      base_date = Gwsub::Sb05Request.get_base_date(date,5)
      check_at = Time.now
    end
    return check_at
  end

  def self.get_base_date(date , media_code)
    case media_code.to_i
    when 1
      # 新聞は、基準日＝開始日
      return date
    when 2
      # 基準日として直前の第２or第４水曜日を取得する
      # 前月第４水曜日・当月第２水曜日・当月第４水曜日を取得
      w_y = date.year
      w_m = date.month
      w_d = 1
      # 前月１日の曜日を取得
      if w_m == 1
        w_y_prev = w_y - 1
        w_m_prev = 12
      else
        w_y_prev = w_y
        w_m_prev = w_m-1
      end
      first_w_prev = Time.local(w_y_prev,w_m_prev,w_d,0,0,0).strftime("%w")
      # 前月第４水曜日を取得
      case first_w_prev.to_i
      when 0
        prev_4_3 = 25
      when 1
        prev_4_3 = 24
      when 2
        prev_4_3 = 23
      when 3
        prev_4_3 = 22
      when 4
        prev_4_3 = 28
      when 5
        prev_4_3 = 27
      else
        prev_4_3 = 26
      end
      # 当月１日の曜日を取得
      first_w_cur = Time.local(w_y,w_m,w_d,0,0,0).strftime("%w")
      # 当月第２・４水曜日を取得
      case first_w_cur.to_i
      when 0
        cur_2_3 = 11
        cur_4_3 = 25
      when 1
        cur_2_3 = 10
        cur_4_3 = 24
      when 2
        cur_2_3 = 9
        cur_4_3 = 23
      when 3
        cur_2_3 = 8
        cur_4_3 = 22
     when 4
        cur_2_3 = 14
        cur_4_3 = 28
      when 5
        cur_2_3 = 13
        cur_4_3 = 27
      else
        cur_2_3 = 12
        cur_4_3 = 26
      end
      # 日付から、週と曜日を取得
      week_no = (date.day.to_i-1).divmod(7)[0]
      week_day = date.wday
#[pp 'sb05_request',date,week_no,week_day]
      case week_no.to_i
      when 0
        # 第１週は、前月の第４週水曜日
        base_date = Time.local(w_y_prev,w_m_prev,prev_4_3,0,0,0)
        return base_date
      when 1
        # 第２週は、日～火は前月の第４週水曜日、水～土は当月第２水曜日
        case week_day.to_i
        when 0..2
          base_date = Time.local(w_y_prev,w_m_prev,prev_4_3,0,0,0)
          return base_date
        else
          base_date = Time.local(w_y,w_m,cur_2_3,0,0,0)
          return base_date
        end
      when 2
        # 第３週は、当月第２水曜日
        base_date = Time.local(w_y,w_m,cur_2_3,0,0,0)
        return base_date
      when 3
        # 第４週は、日～火は当月の第２週水曜日、水～土は当月第４水曜日
        case week_day.to_i
        when 0..2
          base_date = Time.local(w_y,w_m,cur_2_3,0,0,0)
          return base_date
        else
          base_date = Time.local(w_y,w_m,cur_4_3,0,0,0)
          return base_date
        end
      when 4
        # 第５週は、当月第４水曜日
        base_date = Time.local(w_y,w_m,cur_4_3,0,0,0)
        return base_date
      else
        # 該当なしは、基準日を当日とする
        return date
      end
    when 3
      return date
    when 4
      return date
    else
      return date
    end
  end

  def self.creatable_data(user,media_code,role,editor=Core.user_group.code)
    return false if user.blank?
    return false if media_code.blank?
    return true if role == true
    return self.is_editor?(user.org_cd,editor)

    #編集期限取得 →入力時にチェック
#    date  = Time.now
#    check_at = Gwsub::Sb05Request.get_contact_at(self.media_code,date)
#    # 入力された掲載希望日が、編集期限を過ぎている場合は登録不可とする。
#    st_at = Time.now
#    return true if st_at < check_at
    return false
  end

  def self.editable_data(request,role,editor=Core.user_group.code)
    return false if request.blank?
    # 管理者は常時編集可能
    return true if role==true
    # 他所属は不可
    return false unless editor.to_s == request.org_code.to_s
    # 編集期限を過ぎていないか、チェック。　過ぎていたら false：編集不可
    # 期限設定無しはゴミ（メルマガ仮登録）のため、編集・削除許可
    edit_limit_at = request.contract_at
    return true if edit_limit_at.blank?
#    # 期限設定無しは編集不可
#    edit_limit_at = request.contract_at
#    return false if edit_limit_at.blank?
    # 期限チェック（文字列比較）
    limit_day = edit_limit_at.strftime("%Y-%m-%d %H:%M:%S")
    check_day = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    return (check_day < limit_day)? true:false
  end

  def self.editable_admin(request,role)
    return false if request.blank?
    # 承認廃止に伴い、管理者は常時編集可能
    return true
    #管理者は承認完了時のみ
#    if request.r_state.to_i == 3
#      return true if role == true
#    end
  end
  def self.m_status_requests
    Gw.yaml_to_array_for_select 'gwsub_sb05_requests_save_m_state'
  end
  def self.manager_r_status_requests
    Gw.yaml_to_array_for_select 'gwsub_sb05_requests_save_manager_r_state'
  end
  def self.select_state
    Gw.yaml_to_array_for_select 'gwsub_sb05_requests_state'
  end
  def self.select_led_state
    Gw.yaml_to_array_for_select 'gwsub_sb05_requests_led'
  end
  def self.select_mm_state
    Gw.yaml_to_array_for_select 'gwsub_sb05_requests_mm_state'
  end
  def self.select_m_state
    Gw.yaml_to_array_for_select 'gwsub_sb05_m_state'
  end
  def self.display_state(state)
    states = Gw.yaml_to_array_for_select 'gwsub_sb05_requests_state'
    states_show = []
    states.each do |value,key|
      states_show << [key,value]
    end
    show = states_show.assoc(state.to_i)
    return nil if show.blank?
    return show[1]
  end
  def self.display_m_state(state)
    states = Gw.yaml_to_array_for_select 'gwsub_sb05_m_state'
    states_show = []
    states.each do |value,key|
      states_show << [key,value]
    end
    show = states_show.assoc(state.to_i)
    return nil if show.blank?
    return show[1]
  end
  def self.magazine_state(state)
    states = Gw.yaml_to_array_for_select 'gwsub_sb05_requests_mm_state'
    states_show = []
    states.each do |value,key|
      states_show << [key,value]
    end
    show = states_show.assoc(state.to_i)
    return nil if show.blank?
    return show[1]
  end
  def self.select_dd_status( all = nil )
    states = Gw.yaml_to_array_for_select 'gwsub_sb05_requests_state'
    state_list = []
    state_list << ['すべて','0'] if all == 'all'
    states.each do |value,key|
      state_list << [value,key]
    end
    return state_list
  end
  def self.select_dd_m_status( all = nil )
    states = Gw.yaml_to_array_for_select 'gwsub_sb05_m_state'
    state_list = []
    state_list << ['すべて','0'] if all == 'all'
    states.each do |value,key|
      state_list << [value,key]
    end
    return state_list
  end
  def self.select_dd_dates( all = nil ,r_state = nil , media_code = nil)
    dates_list = []
    dates_list << ['すべて','0'] if all == 'all'
#    group = "media_code, categories_code , start_at"
    group = "media_code, start_at"
    select = "media_name, categories_name , start_at"
    order = "media_code ASC , start_at ASC "
    cond = "start_at is not null"
    unless r_state.blank?
      cond << " and r_state = '#{r_state}'"
    end
    unless media_code.blank?
      cond << " and media_code=#{media_code}"
    end

    dates = Gwsub::Sb05Request.group(group).select(select).order(order).where(cond)

    dates.each do |d|
      dates_list << [Gw.date_str(d.start_at),Gw.date_str(d.start_at)]
    end
    return dates_list
  end

  def self.select_dd_base_dates( all = nil , m_state = nil ,r_state = nil , media_code = nil )
    dates_list = []
    dates_list << ['すべて','0'] if all == 'all'
    group   = "media_code, base_at"
    select  = "media_name , base_at"
    order   = "media_code ASC , base_at ASC "
    cond    = "base_at is not null"
    unless (m_state.blank? or m_state.to_i==0)
      cond << " and m_state = '#{m_state}'"
    end
    unless (r_state.blank? or r_state.to_i==0)
      cond << " and r_state = '#{r_state}'"
    end
    unless (media_code.blank? or media_code.to_i==0)
      cond << " and media_code=#{media_code}"
    end
    dates = Gwsub::Sb05Request.group(group).select(select).order(order).where(cond)

    dates.each do |d|
      dates_list << [Gw.date_str(d.base_at),Gw.date_str(d.base_at)]
    end
    return dates_list
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :title,:body1,:user_name,:magazine_url,:telephone
      when 'u_id'
        search_id v, :sb05_users_id   unless v.to_i == 0
      when 'org_code'
        search_keyword v, :org_code     unless v.to_s.blank?
      when 'org_name'
        search_keyword v, :org_name     unless v.to_s.blank?
      when 'media_id'
        search_id v, :media_id        unless v.to_i == 0
      when 'media_code'
        search_id v, :media_code      unless v.to_i == 0
      when 'cat_code'
        search_id v, :categories_code unless v.to_i == 0
      when 'r_status'
        search_id v, :r_state   unless v.to_i==0
      when 'm_status'
        search_id v, :m_state   unless v.to_i==0
#      when 'start_at'
#        search_keyword v, :start_at
      end
    end if params.size != 0

    return self
  end

  def self.alter_table
    connect = self.connection()
    alter_query1 = "ALTER TABLE `gwsub_sb05_requests` CHANGE COLUMN `updated_at` `translate_updated_at` DATETIME DEFAULT NULL;"
    connect.execute(alter_query1)
    alter_query2 = "ALTER TABLE `gwsub_sb05_requests` CHANGE COLUMN `notes_updated_at` `updated_at` DATETIME DEFAULT NULL;"
    connect.execute(alter_query2)
    return
  end

  #--------承認関係↓---------
  #リマインダー通知：担当者→承認者
  def save_recognizers
    r_state  = self.r_state
    if r_state.to_i == 2
        # 申請時の承認依頼
        rec_mode = 1#承認関係統一のために設定。
    end
    # 承認依頼の連絡メモ
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb05_requests_addmemo',options
    d_state = state[0][1]#1: 承認依頼が通知されました。
    s_state = state[1][1]#2: 内容を確認し、承認処理を行ってください。
    self._recognizers.each do |k, v|
      unless v.to_s == ''
        Gwsub::Sb05Recognizer.create(
          :mode =>  rec_mode,
          :parent_id => self.id,
          :user_id => v.to_s
        )
        memo_options={}
        memo_options[:is_system]=1
        Gw.add_memo(v.to_s, "#{d_state}","#{s_state}<br /><a href='/gwsub/sb05//sb05_requests/#{self.id}'><img src='/_common/themes/gw/files/bt_approvalconfirm.gif' alt='承認処理へ'></a>",memo_options) if rec_mode == 1
      end
    end unless self._recognizers.blank?
  end

  #リマインダー通知：承認者→担当者
  def rec_rejected
    user = Gwsub::Sb05User.new
    user.and :id, self.sb05_users_id
    create_user = user.find(:first)
    create_user_id = create_user.user_id
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb05_requests_addmemo',options
    d_state = state[2][1]#3:承認依頼が却下されました。
    s_state = state[3][1]#4:内容を修正し、再度承認依頼を行ってください。
    #担当者連絡先ユーザーに通知
        memo_options={}
        memo_options[:is_system]=1
    Gw.add_memo(create_user_id.to_s, "#{d_state}","<a href='/gwsub/sb05//sb05_requests/#{self.id}'>#{s_state}</a>",memo_options)
  end

  #承認者が一人でもセレクトされているかをチェック
  def validate_recognizers
    if r_state == '2'
      check_validate_recognizers  if  _recognizers
    else
    end
  end

  #申請書に対して承認者全員分を検索
  def recognize_all
    if self.r_state.to_i == 1 || self.r_state.to_i == 2
      # 申請時の承認依頼
      rec_mode = 1
    end
    rec_users = Gwsub::Sb05Recognizer.new
    rec_users.and :mode , rec_mode
    rec_users.and :parent_id, self.id
    rec_users_all =  rec_users.find(:all)
    return rec_users_all
  end

  def find_ansrec_user
    rec_users = Gwsub::Sb05Recognizer.new
    rec_users.and :user_id , Core.user.id
    rec_users.and :parent_id, self.id
    rec_users_all =  rec_users.find(:first)
    if rec_users_all.recognized_at.blank?
      return true
    else
      return false
    end
  end

  def request_open?(r_state)
    case r_state.to_i
    when 4
      show_state = '未処理'
    else
      show_state = '処理済'
    end
    return show_state
  end

  private
  def validate_end_at
    valid  = true
    # 移行データはスキップ
    unless self.notes_imported.blank?
        return valid
    end

    # 終了日チェック　(ラジオ・LEDのみ）

    case self.media_code
    when 2 , 3
      # 入力チェック
      if self.end_at.blank?
        errors.add :end_at, 'を入力してください。'
        valid = false
        return valid
      end
      # 書式チェック
      check_value1 = self.start_at
      if check_value1.blank?
        errors.add :start_at, 'の書式が間違っています'
        valid = false
        return valid
      end
      check_value2 = self.end_at
      if check_value2.blank?
        errors.add :end_at, 'の書式が間違っています'
        valid = false
        return valid
      end
      # 前後関係チェック
      if check_value2 < check_value1
        errors.add :end_at, 'は開始日よりも後の日付を選択して下さい。'
        valid = false
        return valid
      end
    else
    end
    return valid
  end

  def validate_start_at
#pp ['befor_checks','0',req1]
    valid = true
    # 移行データはスキップ
    unless self.notes_imported.blank?
        return valid
    end

    # 共通チェック
    # 入力チェック
    if self.start_at.blank? || self.start_at == '' || self.start_at == nil
      errors.add :start_at, 'を入力してください。'
      valid = false
      return valid
    end
    # 書式チェック
    check_value1 = self.start_at
    if check_value1.blank?
     errors.add :start_at, 'の書式が間違っています'
      valid = false
      return valid
    end

    case self.media_code
    when 1 , 4
      # 掲載予定日チェック　（新聞・メルマガのみ）
      d_date  = Gwsub::Sb05DesiredDate.new
      d_date.media_code = self.media_code
      d_date.order "desired_at ASC"
      dates = d_date.find(:all).collect{|x| Gw.date_str(x.desired_at)}
#pp ['befor_checks','2',check_value,dates]
      if dates.index(Gw.date_str(self.start_at)) == nil
        errors.add :start_at, 'は掲載予定日ではありません。'
        valid = false
        return valid
      end
    else # media_code:2,3
    end

    # 共通チェック
    # 管理者でも、編集期限が取得できない場合はエラー（基準日がないのは、登録期間外とする）
    contract_at = Gwsub::Sb05Request.get_contract_at(self.media_code,self.start_at,self.end_at)
    if contract_at.blank?
        errors.add :start_at, 'から編集期限を設定できません。'
        valid = false
        return valid
    end
    # 管理者は期限チェックなし
    user_role = Gwsub::Sb05Request.is_dev? || Gwsub::Sb05Request.is_admin?
    if user_role==true
      return valid
    end

    limit_day = contract_at.strftime("%Y-%m-%d %H:%M:%S")
    check_day = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    if check_day < limit_day
    else
      errors.add :start_at, 'は編集期限を過ぎています。'
      valid = false
      return valid
    end
    return valid
  end

  def validate_file_size_check
    unless self.notes_imported.blank?
      return true
    end
    if self.media_code==4 && self.categories_code==2
      item = Gwsub::Sb05Request.find(self.id)
      file = Gwsub::Sb05File.new
      file.and :parent_id,item.id
      files = file.find(:all)
      media = Gwsub::Sb05MediaType.new
      media.and :media_code,item.media_code
      media.and :categories_code,item.categories_code
      media = media.find(:first)
      set_size = media.max_size.to_i * 1000 * 1000
      files.each do|f|
        if f.size  > set_size
        errors.add :size, '画像サイズが大きすぎるファイルが含まれています。'
        end
      end
    end
  end

  def validate_magazine_url
    unless self.notes_imported.blank?
      return true
    end
    # メルマガ以外は対象外
    return true if self.media_code!=4
    # メルマガ　イベント情報は、任意
    return true if self.media_code==4 and self.categories_code==2
    # メルマガ　情報ボックスのPC版URLは必須
    return true unless self.magazine_url.blank?
    errors.add :magazine_url, 'を入力してください。'
    return false
  end
end
