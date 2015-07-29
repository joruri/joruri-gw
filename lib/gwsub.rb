# encoding: utf-8
class Gwsub

  def self.modelize(table_name)
    name = table_name.singularize
    name1 = name.split('_')
    name2 = name1.collect{|x| x.capitalize}
    name3 = []
    name2.each_with_index do |name,idx|
      if idx == 0
      else
        name3 << name
      end
    end
    name4 = name3.join('')
    name5 = name2[0]+'::'+name4
    return name5
  end

  # for sb05 newspaper
  def self.rep_space(rep_str)
    # 特定文字列を半角スペースに変換
    sp_str = rep_str.to_s.tr('_',' ')
    # 特定文字列を全角スペースに変換
    sp_str = sp_str.to_s.tr('＿','　')
    return sp_str
  end
  def self.space_del(sp_str)
    # 全角スペース削除
    del_str = sp_str.to_s.tr('　','')
    # 半角スペース削除
    del_str = del_str.to_s.tr(' ','')
    return del_str
  end
  def self.num_zen_to_han(zen_str)
    han_str = zen_str.to_s.tr('０-９','0-9')
    return han_str
  end

  # 共通　英数字・記号の半角処理
  def self.convert_char_ascii(_str)
    _str_ascii = _str.to_s.tr("#{[0xff01].pack("U")}-#{[0xff5e].pack("U")}","#{[0x21].pack("U")}-#{[0x7e].pack("U")}")
    return _str_ascii
  end

  # 研修申込受付　開催時刻選択
  def self.select_times
    range = Gw.yaml_to_array_for_select 'gwsub_sb01_training_time_range'
    selects = []
    count = range[0][0].to_i
    while count <= range[1][0].to_i
      if count.to_i == 12
        # 研修は、12時開始をスキップ
      else
        time_str = sprintf("%02d",count)+":00"
        selects << [time_str,time_str]
      end
      count = count + 1
    end
    return selects
  end
  # 研修申込受付　開催時刻選択
  def self.select_times_end
    range = Gw.yaml_to_array_for_select 'gwsub_sb01_training_time_range_end'
    selects = []
    count = range[0][0].to_i
    while count <= range[1][0].to_i
      if count.to_i == 13
        # 研修は、13時終了をスキップ
      else
        time_str = sprintf("%02d",count)+":00"
        selects << [time_str,time_str]
      end
      count = count + 1
    end
    return selects
  end
  # 端末管理　アドレス系結合
  def self.ip_concat(_ip1,_ip2,_ip3,_ip4)
    _ip = ''
    _ip << _ip1.to_s
    _ip << '.'
    _ip << _ip2.to_s
    _ip << '.'
    _ip << _ip3.to_s
    _ip << '.'
    _ip << _ip4.to_s
    return _ip
  end

## ログインユーザーから　作成者・編集者　関連項目の設定
  def self.gwsub_set_creators(item)
    return if Site.user.blank?
    item.created_user   = Site.user.name
    item.created_group  = Site.user_group.code+Site.user_group.name
  end
  def self.gwsub_set_editors(item)
    return if Site.user.blank?
    item.updated_user   = Site.user.name
    item.updated_group  = Site.user_group.code+Site.user_group.name
  end

  # 日付を和暦年度に変換
  def self.fyear_to_namejp(date = nil)
    return nil if date.to_s.blank?
    dates = Gw.date_str(date).split('-')
    fyears = Gw::YearFiscalJp.get_record(date)
    show_str = ''
    if fyears.blank?
    else
      show_str = fyears.namejp + '年　' + sprintf("%d",dates[1].to_i) + '月　'+ sprintf("%d",dates[2].to_i) + '日　'
    end
    return show_str
  end

  # 日付を和暦年(年度では無いので注意)に変換
  def self.fyear_to_namejp2(date = nil , options={} )
    # options
    # :d 日表示　1:空白、2:表示　（空白の場合、平成nn年 01月　　日 で日の欄を記入用に空白で表示する）
    disp_day  = nz(options[:d],2)
    return nil if date.to_s.blank?
    dates = Gw.date_str(date).split('-')
    dates2 = Gw.date_str(date).split('-')
    if dates[1].to_i < 4
      dates2[1]=4
      date2 = Time.local(dates2[0],dates2[1],dates2[2],'00','00','00')
    else
      date2 = date
    end
    fyears = Gw::YearMarkJp.convert_ytoj(dates,'3','1')
    show_str = ''
    if fyears.blank?
    else
      case disp_day.to_i
      when 1
        show_str = fyears[2] + '年　' + sprintf("%d",dates[1].to_i) + '月　'+ '　　' + '日　'
      when 2
        show_str = fyears[2] + '年　' + sprintf("%d",dates[1].to_i) + '月　'+ sprintf("%d",dates[2].to_i) + '日　'
      else
      end
    end
    return show_str
  end

  # 選択年度　取得
  def self.set_fy_selected_id( id = nil, option = {} )
#pp ['set_fy_selected_id',id,option]
    # option :name=>column_name,:value=>value
    #  西暦年度：{'fyear'  , 'yyyy'}
    #  記号年度：{'markjp' , 'Hyy'}
    #  和暦年度：{'namejp' , '平成yy'}
    #  指定なし：最新年度
    # 戻り値はid
    # id指定では、存在チェック　みつかればOK
#    if id != nil
    if id.to_i != 0
     fy = Gw::YearFiscalJp.find_by_id(id)
      return id unless fy.blank?
    end
    f_id = nil
    # id指定なし、id-notfound1では、option指定に応じて設定
    if option == nil
      # 開始日が最新の年度idを返す
      order = "start_at DESC"
      fyear = Gw::YearFiscalJp.find(:first,:order=>order)
      f_id = fyear.id unless fyear.blank?
      return f_id
    end
    case option[:name]
    when 'fyear'
      cond = "fyear='#{option[:value]}'"
      order = "start_at DESC"
      fyear = Gw::YearFiscalJp.find(:first,:conditions=>cond,:order=>order)
      f_id = fyear.id unless fyear.blank?
    when 'markjp'
      cond = "markjp='#{option[:value]}'"
      order = "start_at DESC"
      fyear = Gw::YearFiscalJp.find(:first,:conditions=>cond,:order=>order)
      f_id = fyear.id unless fyear.blank?
    when 'namejp'
      cond = "namejp='#{option[:value]}'"
      order = "start_at DESC"
      fyear = Gw::YearFiscalJp.find(:first,:conditions=>cond,:order=>order)
      f_id = fyear.id unless fyear.blank?
    else
      #
    end
    return f_id
  end

  # 選択年度設定
  def self.set_fyear_select(fy_id = nil, option = nil)
    unless fy_id == nil
      # 年度ID指定時は存在チェック
      return 0 if fy_id.to_i==0
      fyear = Gw::YearFiscalJp.find(fy_id)
      return fy_id unless fyear.blank?
      return 0     if     fyear.blank?
    end

    case option
    when 'init'
      # 無条件初期値
      fyed_id = 0
    when 'sb09_terminal_replace_reflections'
      # 端末管理　ＰＣ更新反映
      fyed_id = 0
    when 'terminal_admin_memos'
      # 端末管理の管理者メモから取得
      find_order = "fyear_id DESC , id ASC"
      fyear = Gwsub::TerminalAdminMemo.find(:all,:order=>find_order)
      if fyear.blank?
        fyed_id = 0
      else
        fyed_id = fyear[0].fyear_id
      end
    when 'help'
      # 職員名簿のヘルプから取得
      find_order = "fyear_id DESC , title ASC"
      help = Gwsub::Sb04help.find(:all,:order=>find_order)
      if help.blank?
        fyed_id = 0
      else
        fyed_id = help[0].fyear_id
      end
    else
      # 職員名簿の最新所属年度から取得
      u_role  = option[:role]
      if u_role == true
        # 管理者は公開前の年度を含む
        find_order = "start_at DESC"
        find_year = Gwsub::Sb04EditableDate.find(:first,:order=>find_order)
      else
        # 一般は公開後の最新年度
        today = Core.now
        find_cond = "published_at <='#{today}'"
        find_order = "start_at DESC"
        find_year = Gwsub::Sb04EditableDate.find(:first,:conditions=>find_cond,:order=>find_order)
      end
      if find_year.present?
        fyed_id = find_year.fyear_id
      else
        fyed_id = fy_id.to_i
      end
    end
    return fyed_id
  end

  # sb04 職員名簿
  def self.set_section_select( fyear_id = nil , section_id = nil ,all=nil)
  # 職員名簿の所属から選択指定の設定
    section_selected = 0
    return section_selected if all=='all'
    unless section_id.to_i == 0

      sec = Gwsub::Sb04section.find(section_id.to_i)
      section_selected = section_id  unless  sec.blank?
      section_selected = 0           if      sec.blank?
      return section_selected
    end
    if fyear_id.to_i  == 0
        find_order = "fyear_id DESC , code ASC"
        sec = Gwsub::Sb04section.find(:all,:order=>find_order)
    else
        find_cond = "fyear_id = #{fyear_id.to_i}"
        find_order = "code ASC"
        sec = Gwsub::Sb04section.find(:all,:conditions=>find_cond,:order=>find_order)
    end
    section_selected = 0             if  sec.blank?
    section_selected = sec[0].id unless  sec.blank?
    return section_selected
  end

  # 所属選択指定の設定
  def self.set_org_sel(sec_id=0,all=nil,role=true)
    # sec_id : 指定所属
    # all    : 'all' すべて
    # role   : 管理者権限

    # 管理者以外はユーザーの所属
    if role != true
      return Site.user_group.id
    end

    #所属指定時は存在チェック
    ids = System::Group.find(:all).collect{|x| x.id}
    check = ids.index(sec_id.to_i)
    return sec_id  if check != nil

    # role == true , sec_id == 0
    # すべて指定時は、0
    return 0 if all=='all'

    # 管理者は、「すべて」「指定所属」がなければ、トップ
    top = System::Group.find(:first,:conditions=>"level_no=1")
    return 0 if top.blank?
    return top.id
  end

  def self.set_group_select(fyear_id = nil , section_id = nil, option = nil)
    # 所属選択　設定
    # fyear_id : 対象年度
    # section_id : 所属
    # option : 未実装

    # 対象年度開始日取得
    if fyear_id.to_i==0
      target_fyear_id = Gw::YearFiscalJp.get_record(Time.now).id
    else
      target_fyear_id = fyear_id
    end
    target_start_at = Gw::YearFiscalJp.find(target_fyear_id).start_at.strftime("%Y-%m-%d 00:00:00")
    # 所属指定時は存在・有効チェック
    unless section_id.to_i==0
      group_cond    = "state='enabled'"
      group_cond    << " and start_at <= '#{target_start_at}'"
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at >= '#{target_start_at}' ) "
      group_order   = "sort_no , code , start_at DESC, end_at IS Null ,end_at DESC"
      gid_lists = System::Group.find(:all,:conditions=>group_cond,:order=>group_order).map{|x| x.id}
      check = gid_lists.index(section_id.to_i)
      unless check.blank?
        return section_id
      end
    end
    # 有効な所属リストの先頭のidを返す
    child_cond    = "state='enabled' and level_no=3"
    child_cond    << " and start_at <= '#{target_start_at}'"
    child_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at >= '#{target_start_at}' ) "
    child_order   = "sort_no , code , start_at DESC, end_at IS Null ,end_at DESC"
    child1 = System::Group.find(:first,:conditions=>child_cond,:order=>child_order)
    if child1.blank?
      sec_id = 0
    else
      sec_id = child1.id
    end
    return sec_id
  end

  def self.set_current_group_select(fyear_id = nil , section_id = nil, option = nil)
    # 所属選択　設定
    # fyear_id : 対象年度
    # section_id : 所属
    # option : 未実装

    # 対象年度開始日取得
    if fyear_id.to_i==0
      target_fyear_id = Gw::YearFiscalJp.get_record(Time.now).id
    else
      target_fyear_id = fyear_id
    end
    target_start_at = Gw::YearFiscalJp.find(target_fyear_id).start_at.strftime("%Y-%m-%d 00:00:00")
    today_at      = Time.now.strftime("%Y-%m-%d 00:00:00")
    # 所属指定時は存在・有効チェック

    unless section_id.to_i==0
      section = System::Group.find_by_id(section_id)
      if section.blank?
        # 指定IDが使えない場合は先頭IDの取得に回る
      else
        if section.state=='enabled'
          # 有効
          if section.end_at.to_s.blank?
            # 終了していない
            return section_id
          else
            if section.end_at.strftime("%Y-%m-%d 00:00:00") > today_at
              # 終了日が今日より後
              return section_id
            end
          end
        end
      end
    end
    # 有効な所属リストの先頭のidを返す
    child_cond    = "state='enabled' and level_no=3"
    child_order   = "sort_no , code"
    child1 = System::Group.find(:first,:conditions=>child_cond,:order=>child_order)
    if child1.blank?
      sec_id = 0
    else
      sec_id = child1.id
    end
    return sec_id
  end

  # 機器区分選択指定の設定
  def self.set_division_select(div_id = nil , target = nil , option = nil)
    # 指定のコードに対応するidを返す
    # division: id 指定時の妥当性チェック
    # target:   選択指定の固定対象 (呼び出し元キーワード)
    # option:   'init':設定必須

    div_init_id = 0
    # PC更新は機器区分「パソコン」固定
    # 余剰PCは機器区分「パソコン」固定
    case target
    when 'replace_pc','surplus_pc'
      item = Gwsub::Sb09TerminalDivision.new
      item.code = '2'
      item.state  = 'enabled'
      item.order "code_int ASC"
      items = item.find(:all)
        if items.blank?
          div_init_id = 0
        else
          div_init_id = items[0].id
        end
        return div_init_id
    else
    end
    # target 指定が無い場合
    case option
    when 'init'
      # 設定必須であれば、指定値または先頭値
      # div_id指定があれば、存在チェック
      if div_id.to_s.blank?
      else
        ids = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" , :order=>"id").collect{|x| x.id.to_i}
        check = ids.index(div_id.to_i)
        div_init_id = div_id  unless check==nil
        return div_init_id
      end
      # 指定値が見つからない、またはid指定が無ければ、機器区分の先頭
      find_order = "code_int ASC"
      items = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'"  , :order=>find_order)
      if div_id.to_s.blank?
        if items.blank?
          div_init_id = 0
        else
          div_init_id = items[0].id
        end
        return div_init_id
      end
    else
      if div_id.to_s.blank?
        div_init_id = 0
        return div_init_id
      end
      # div_id指定があれば、存在チェック
      ids = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" , :order=>"id").collect{|x| x.id.to_i}
      check = ids.index(div_id.to_i)
      div_init_id = div_id  unless check==nil
      div_init_id = 0       if check==nil
      return div_init_id
    end
    # すべてのチェックをスルーした場合
    return div_init_id

  end

  # メーカー選択初期値
  def self.set_maker_select(div_id = nil , maker_id = nil , all = nil )
    if all == 'all'
      return 0
    end
    if div_id.to_i == 0
      return 0
    end
    if maker_id.to_i != 0
      ids = Gwsub::Makername.find(:all, :conditions=>"state!='deleted'" ,:order=>"id").collect{|x| x.id}
      check = ids.index(maker_id.to_i)
      if check == 0
        return 0
      else
        return maker_id
      end
    end
    maker = Gwsub::Makername.new
    maker.equipmentdivision_id = div_id.to_i
    maker.state='enabled'
    maker.order "name"
    makers = maker.find(:all)
    return 0 if makers.blank?
    return makers[0].id unless makers.blank?
  end

  # 機器区分選択リストの設定
  def self.get_division_list( all = nil , exclusion = nil )

    find_order = "code_int ASC"
    items = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" ,:order=>find_order)
    division_list = []
    if items.blank?
      division_list << ['機器区分未設定','0']
    else
      division_list << ['すべて','0'] if all == 'all'
      items.each do |item|
        if exclusion == nil
          division_list << [item.name,item.id]
        else
          division_list << [item.name,item.id] if exclusion != item.name
        end
      end
    end
    return division_list
  end
  # メーカー選択リストの設定
  def self.get_maker_list( div_id = nil , all = nil)
    # div_id　選択対象の機器区分ID
    # all     選択リストに'すべて'を含む指定   'all':含む
    maker_list = []
    # メーカー名　選択DD
    if div_id.to_i == 0
      if all == nil
        maker_list << ['機器区分未選択','0']
      else
        maker_list << ['すべて','0']
      end
      return maker_list
    end
    find_order = "code_int ASC"
    divisions = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" ,:order=>find_order)
    if divisions.blank?
      # 機器区分　未設定で終了
      maker_list << ['機器区分未設定','0']
      return maker_list
    end
    # 機器区分 ID指定の場合
    ids = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" ,:order=>"id").collect{|x| x.id}
    check = ids.index(div_id.to_i)
    return maker_list << ['機器区分未定','0'] if check == nil
    division_id = div_id.to_i unless check == nil

    # メーカーリスト抽出
    find_condition = "state!='deleted' and equipmentdivision_id=#{division_id} and select_list=1"
    find_order = "name ASC"
    makers = Gwsub::Makername.find(:all,:conditions=>find_condition,:order=>find_order)
    if makers.blank?
      maker_list << ['メーカー未設定','0']
    else
      maker_list << ['すべて','0'] if all == 'all'
      makers.each do |maker|
        maker_list << [maker.name,maker.id]
      end
    end
    return maker_list
  end
  # ＯＳ選択リストの設定
  def self.get_os_list( div_id = nil , all = nil)
    # div_id　選択対象の機器区分ID
    # all     選択リストに'すべて'を含む指定   'all':含む
    os_list = []
    if div_id.to_i == 0
      if all == nil
        os_list << ['機器区分未選択','0']
      else
        os_list << ['すべて','0']
      end
      return os_list
    end
    # 対象機器区分　初期設定
    find_order = "code_int ASC"
    divisions = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" ,:order=>find_order)
    if divisions.blank?
      # 機器区分　未設定で終了
      os_list << ['機器区分未設定','0']
      return os_list
    end
    # 機器区分 ID指定の場合
    ids = Gwsub::Sb09TerminalDivision.find(:all , :conditions=>"state!='deleted'" ,:order=>"id").collect{|x| x.id}
    check = ids.index(div_id.to_i)
    return os_list << ['機器区分未定','0'] if check == nil
    division_id = div_id.to_i unless check == nil

    # ＯＳリスト抽出
    div = Gwsub::Sb09TerminalDivision.find(division_id)
    if div.code == '3'
        os_list << ['OS設定対象外','0']
    else
      find_condition = "state!='deleted' and equipmentdivision_id=#{division_id} and select_list=1"
      find_order = "sort_order ASC"
      oss = Gwsub::Operatingsystem.find(:all,:conditions=>find_condition,:order=>find_order)
      if oss.blank?
        os_list << ['ＯＳ未設定','0']
      else
        os_list << ['すべて','0'] if all == 'all'
        oss.each do |os|
        os_list << [os.name,os.id]
        end
      end
    end
    return os_list
  end

  def self.grouplist4(fyear_id=nil, all = nil, role = true ,top = nil ,parent_id=nil, options = {})
    # 所属選択DD用ツリー
    # fyear_id 対象年度id
    # all   選択リストに'すべて'を含む指定   'all':含む
    # role : 権限
    # top : true の時は、level_no =1 から表示
    # parent_id : 指定があれば、上位部署で絞る
    # options[:return_pattern] : オプション。返り値の設定。空欄、もしくは0なら従来のセレクトボックス用文字列を返す。2010/07/30追加。松木。
    #  1：groupの実体も同時に返す
    #  2：parent_idも同時に返す
    # options[:checkup] : true 健康診断申込からの要求で、教育委員会（level2 code 500）を除外
    # options[:code] : 'none' 所属選択リストで、所属コードをつけないパターン
    # options[:fyear] : true fyear_idを使用する。デフォルトは今日の日付
    # options[:kouann] : true 公安委員会表示許可
    # options[:through_state] : true stateを見ない　//政策評価用
    # options[:show_ids] : 1,2,3.. カンマ区切りで取得するID指定　//政策評価用(公安委員会用)

    # 年度指定が無ければ、今日を含む年度
    if fyear_id.to_i==0
      fyear_target = Gw::YearFiscalJp.get_record(Time.now)
      if fyear_target.blank?
        fyear_target_id = Gw::YearFiscalJp.find(:first, :order=>"fyear DESC , start_at DESC").id
      else
        fyear_target_id = fyear_target.id
      end
    else
      fyear_target_id = fyear_id
    end
    #年度開始日取得
      fyear = Gw::YearFiscalJp.find(fyear_target_id)
      start_at_fyear  = fyear.start_at
      end_at_fyear  = fyear.end_at
    # 管理者権限がなければ、自所属のみ表示
    if role != true
      grp = Site.user_group
      group_select = []
      if options.has_key?(:code) and options[:code] == 'none'
        group_select << [grp.name,grp.id]
      else
        group_select << ['('+grp.code+')'+grp.name,grp.id]
      end
      return group_select
    end

    current_time = Time.now
    current_time = end_at_fyear if options.has_key?(:fyear) and options[:fyear] == true

    #状態での絞り込み無し
    if options[:through_state]
      state_cond = ""
    else
      state_cond = "state='enabled' and "
    end

    # 親指定があれば、level2は指定のid
    group_cond = "#{state_cond} level_no=2"

    group_cond += " and id=#{parent_id}"  unless parent_id.to_i==0
    if options.has_key?(:fyear) and options[:fyear] == true
      # 開始日・終了日を指定年度の日時で判定
      group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{start_at_fyear.strftime("%Y-%m-%d 23:59:59")}' ) "
    else
      # 開始日・終了日を現在日時で判定
      # 開始日が過去日時
      group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      # 終了日が将来日時
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    end

    group_order   = "code , sort_no , start_at DESC, end_at IS Null ,end_at DESC"
    group_parents = System::Group.find(:all,:conditions=>group_cond,:order=>group_order)
    # 選択DD　作成
    group_select = []
    if group_parents.blank?
      group_select << ["所属未設定",0]
      return group_select
    end
    # all option
    group_select << ["すべて",0]  if all == 'all'
    # level_no = 1
    if top == true
      top_g  = System::Group.find(1)
      if options.has_key?(:code) and options[:code] == 'none'
        group_select << [top_g.name,top_g.id]
      else
        group_select << ['('+top_g.code+')'+top_g.name,top_g.id]
      end
    end
    # level_no = 2 で繰返し
    for group in group_parents

      if options[:through_state]
        child_cond    = "level_no=3 and parent_id=#{group.id}"
      else
        child_cond    = "state='enabled' and level_no=3 and parent_id=#{group.id}"
      end

      if options.has_key?(:fyear) and options[:fyear] == true
        # 開始日・終了日を指定年度の日時で判定
        # ID指定有
        if options.has_key?(:show_ids)
          child_cond   << " and (start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}' or id IN (#{options[:show_ids]}) )"
        else
          child_cond   << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
        end
      else
        # 開始日・終了日を現在日時で判定
        # 開始日が過去日時
        child_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      end
      child_order   = "code , sort_no , start_at DESC, end_at IS Null ,end_at DESC"
      children = System::Group.find(:all,:conditions=>child_cond,:order=>child_order)
      unless children.blank?
        # level_no = 3
        children.each_with_index do |child , i|
          # level_no = 2 を設定　（level2はlevel3筆頭課のidを設定）
          if i == 0 and options.has_key?(:code) and options[:code] == 'none'
            group_select  << ["#{group.name}", group.id]
          else
            group_select << ["(#{group.code})#{group.name}" , child.id] if i == 0 && (options[:return_pattern].blank? || options[:return_pattern] == 0)
            group_select << ["(#{group.code})#{group.name}", child.id, group ] if i == 0 && options[:return_pattern] == 1
            group_select  << ["(#{group.code})#{group.name}", group.id] if i == 0 && options[:return_pattern] == 2
          end
          # level_no = 3 を設定
          if options.has_key?(:code) and options[:code] == 'none'
            group_select << ["　　 - #{child.name}" , child.id]
          else
            group_select << ["　　 - (#{child.code})#{child.name}", child.id] if options[:return_pattern].blank? || options[:return_pattern] == 0
            group_select << ["　　 - (#{child.code})#{child.name}", child.id, child] if options[:return_pattern] == 1
            group_select << ["　　 - (#{child.code})#{child.name}", child.id] if options[:return_pattern] == 2
            group_select << [child.name, "child_group_#{child.id}"] if options[:return_pattern] == 3 # スケジューラー登録画面での所属検索用
            group_select << [child.name, "#{child.id}"] if options[:return_pattern] == 4 # スケジューラー登録画面での所属検索用
          end
        end
      end
    end
    return group_select
  end

  def self.section_manager_names(fyear_id=nil, all = nil, role = true ,top = nil ,parent_id=nil, options = {})

    # 管理者権限がなければ、自所属のみ表示
    item = Gwsub::Sb00ConferenceSectionManagerName.new
    item.and :state, 'enabled'
    item.and :g_code, Site.user_group.code unless role
    item.order :g_sort_no
    items = item.find(:all, :group=>:gid)
    group_select = []
    for item in items
      group_select << [%Q{(#{item.g_code}) #{item.g_name}}, item.gid]
    end
    return group_select
  end

  def self.user_list_fyear(fyear_id=nil , gid=nil , all=nil , role=false , options={} )
#pp Time.now , fyear_id , gid , all , role , options
    # ユーザー選択リスト
    # fyear_id 対象年度id
    # gid   対象の所属id、指定がない場合は、ログインユーザーの所属 (Site.user_group.id)
    # all   選択リストに'すべて'を含む指定   'all':含む
    # options{}  権限：role=>true/false  、年度末：temp=>true/false

    if gid.to_i==0
      if options.has_key?('temp') and options[:temp]==true
        u_cond  = "user_id=#{Site.user.id} and (end_at is null) "
        u_order = "user_code"
        current_user = System::UsersGroupHistoryTemporary.find(:first , :conditions=>u_cond ,:order=>u_order)
        if current_user.blank?
          gid = Site.user_group.id
        else
          gid = current_user.group_id
        end
      else
        gid = Site.user_group.id
      end
    else
    end
    # 年度指定が無ければ、今日を含む年度
    if fyear_id.to_i==0
      fyear_cond = "start_at <= '#{Time.now.strftime("%Y-%m-%d 00:00:00")}'"
      fyear_order = "markjp DESC"
      fyear_target = Gw::YearFiscalJp.find(:first,:donditions=>fyear_cond,:order=>fyear_order).id
    else
      fyear_target = fyear_id
    end
    #年度開始日取得
    if options.has_key?(:start_at)
      start_at_fyear  = options[:start_at]
    else
      start_at_fyear  = Gw::YearFiscalJp.find(fyear_target).start_at
    end
    if options.has_key?(:temp) and options[:temp]==true
      # 所属内のユーザーid一覧を取得
      users_cond  = "group_id=#{gid}"
      users_cond  << " and start_at <= '#{start_at_fyear.strftime("%Y-%m-%d 00:00:00")}'"
      users_cond  << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at >= '#{start_at_fyear.strftime("%Y-%m-%d 00:00:00")}' ) "
      users_order = "user_code"
      users = System::UsersGroupHistoryTemporary.find(:all,:conditions=>users_cond,:order=>users_order)
      # ユーザーid一覧から選択リスト作成
      user_lists = []
      user_lists << ['すべて',0] if all=='all'
      users.each do |u|
        us = System::User.find_by_id(u.user_id)
        unless us.blank?
          if Site.user.code.size < 4 or Site.user.code == 'gwbbs'
            # テストユーザーログインでは、非同期ユーザーも選択
            user_lists << [us.name+'('+us.code+')',us.id] if us.state=='enabled'
          else
            # 通常は、LDAP同期ユーザーから選択
            user_lists << [us.name+'('+us.code+')',us.id] if (us.state=='enabled' and us.ldap==1)
          end
        end
      end
    else
      # 所属内のユーザーid一覧を取得
      users_cond  = "group_id=#{gid}"
      users_cond  << " and start_at <= '#{start_at_fyear.strftime("%Y-%m-%d 00:00:00")}'"
      users_cond  << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at >= '#{start_at_fyear.strftime("%Y-%m-%d 00:00:00")}' ) "
      users_order = "user_code"
      users = System::UsersGroupHistory.find(:all,:conditions=>users_cond,:order=>users_order)
      # ユーザーid一覧から選択リスト作成
      user_lists = []
      user_lists << ['すべて',0] if all=='all'
      users.each do |u|
        us = System::User.find_by_id(u.user_id)
        unless us.blank?
          user_lists << [us.name+'('+us.code+')',us.id] if us.state=='enabled'
        end
      end
    end
    return user_lists
  end

  def self.get_branch_list( fyear_id  = nil ,  group_id =nil, all = nil )
    # 年度・所属　から　はなれ一覧を取得
#pp [ fyear, group, all]
    branch_select=[]
    if fyear_id.to_i==0
      branch_select << ['年度未指定',0]
      return branch_select
    end
    if group_id.to_i==0
      branch_select << ['所属未指定',0]
      return branch_select
    end

    cond  = []
    cond  << "state = 'enabled' "
    cond  << "fyear_id = #{fyear_id}" unless fyear_id.to_i==0
    cond  << "group_id = #{group_id}" unless group_id.to_i==0
    cond1 = cond.join(" and ") unless cond.blank?
    order = "markjp DESC, org_code ASC, branch_name ASC"
    branches = Gwsub::Sb09OrganizationBranch.find(:all , :order=>order , :conditions=>cond1)
    if branches.blank?
      branch_select << ['はなれ未設定',0]
    else
      branch_select << ['すべて',0] if all == 'all'
       branches.each do |b|
          branch_select << [b.branch_name,b.id]
       end
    end
    return branch_select
  end
  def self.get_branch_temporary_list( fyear_id  = nil ,  group_id =nil, all = nil )
    # 年度・所属　から　はなれ一覧を取得
    branch_select=[]
    if fyear_id.to_i==0
      branch_select << ['年度未指定',0]
      return branch_select
    end
    if group_id.to_i==0
      branch_select << ['所属未指定',0]
      return branch_select
    end

    cond  = []
    cond  << "state = 'enabled' "
    cond  << "fyear_id = #{fyear_id}" unless fyear_id.to_i==0
    cond  << "group_id = #{group_id}" unless group_id.to_i==0
    cond1 = cond.join(" and ") unless cond.blank?
    order = "markjp DESC, org_code ASC, branch_name ASC"
    branches = Gwsub::Sb09OrganizationBranchTemporary.find(:all , :order=>order , :conditions=>cond1)
    if branches.blank?
      branch_select << ['はなれ未設定',0]
    else
      branch_select << ['すべて',0] if all == 'all'
       branches.each do |b|
          branch_select << [b.branch_name,b.id]
       end
    end
    return branch_select
  end

  def self.get_subnet_id_list
    cond = "state!='deleted' and maskbit!=0 and select_list=1"
    order = "maskbit DESC"
    items = Gwsub::Sb09SubnetMask.find(:all,:conditions=>cond,:order=>order)
    subnet = []
    items.each do |s|
      subnet << ["#{s.mask}/#{s.maskbit}",s.id]
    end
    return subnet
  end
  def self.get_gw_id_list
    order = "dgw1 ASC , dgw2 ASC , dgw3 ASC , dgw4 ASC"
    items = Gwsub::Sb09DefaultGateway.find(:all, :conditions=>"state!='deleted'" ,:order=>order)
    dgw = []
    items.each do |s|
      dgw << [s.dgw,s.id]
    end
    return dgw
  end
  def self.get_dns_id_list
    order = "sort_order ASC , dns1 ASC , dns2 ASC , dns3 ASC , dns4 ASC"
    items = Gwsub::Sb09DomainNameServer.find(:all, :conditions=>"state!='deleted'" ,:order=>order)
    dns = []
    items.each do |s|
      dns << [s.dns,s.id]
    end
    return dns
  end
  def self.get_subnet_list

    _cond = "state!='deleted' and maskbit!=0 and select_list=1"
    _order = "maskbit DESC"
    items = Gwsub::Sb09SubnetMask.find(:all,:conditions=>_cond,:order=>_order)
    subnet = []
    items.each do |s|
      subnet << ["#{s.mask}/#{s.maskbit}","#{s.mask}"]
    end
    return subnet
  end
  def self.get_gw_list
    _order = "dgw1 ASC , dgw2 ASC , dgw3 ASC , dgw4 ASC"
    items = Gwsub::Sb09DefaultGateway.find(:all, :conditions=>"state!='deleted'" ,:order=>_order)
    dgw = []
    items.each do |s|
      dgw << [s.dgw,s.dgw]
    end
    return dgw
  end
  def self.get_dns_list
    _order = "dns1 ASC , dns2 ASC , dns3 ASC , dns4 ASC"
    items = Gwsub::Sb09DomainNameServer.find(:all, :conditions=>"state!='deleted'" ,:order=>_order)
    dns = []
    items.each do |s|
      dns << [s.dns,s.dns]
    end
    return dns
  end
  def self.get_nkf_list
    nkf_list = [
      ['UTF8','w'],
      ['SJIS','s']
    ]
    return nkf_list
  end

  #---------------------------------------------------- temp
  # Gwsub::Public::Sb09::Sb090703menuHelper
  #
  def self.get_columns(table_name)
    column_names = []
    if table_name.nil?
      return %Q(<div class="notice">表示する情報はありません。</div>)
    else
      cols = eval(Gwsub.modelize(table_name)).column_names
      trans_hash_raw = Gw.load_yaml_files
    end

    if trans_hash_raw[table_name].nil?
      return cols.join(':')
    else
      cols.each do |col|
        next if col=='id'
        #split_trans = col[1].split(':')
        if trans_hash_raw[table_name].nil? || trans_hash_raw[table_name][col].nil?
          column_names.push col
        else
          split_trans = trans_hash_raw[table_name][col].split(':')
          case split_trans[0]
          when 'd', 'r', 'n', 'dbraw','D'
            column_names.push split_trans[1]
          when 'x'
          else
            if split_trans[0]!='　'
              # 全角スペースのみの項目は除外
              column_names.push split_trans[0]
            end
          end
        end
      end
    end
    return column_names.join(':')
  end
  def self.get_model_counts(table_name)
    modelname = ""
    if table_name.nil?
      count = 0
    else
      modelname = eval(Gwsub.modelize(table_name))
      count = modelname.count(:all)
    end
    return count
  end

  def self.sb09_get_model_counts(table_name)
    modelname = ""
    if table_name.nil?
      count = 0
    else
      modelname = eval(Gwsub.modelize(table_name))
      m_cond  = "state!='deleted'"
      count = modelname.count(:all , :conditions=>m_cond)
    end
    return count
  end

  def self.sb09_check_pcname_exc(exc , item)
    # コンピューター名の再設定
    return false if exc.blank?
    return false if item.blank?
    # exc ：exclusion 対象外の設定
    # ret false（対象外ではないのでNG） / true（対象外でOK）
    pc_name = item.terminal_pc_name
    ret =false
    exc.each do |ck|
      # 設定済みの文字列をチェック用に取り出し
      len = ck[0].size
      str = ck[0]
      # コンピューター名の先頭から文字数比較
      check_str = pc_name.slice(0,len)
      if check_str.to_s==str.to_s
        # 対象外設定と一致すればOK
        ret =true
        break
      else
        next
      end
    end
    return ret
  end
end
