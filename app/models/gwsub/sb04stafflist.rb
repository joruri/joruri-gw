# -*- encoding: utf-8 -*-
class Gwsub::Sb04stafflist < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to  :fy_rel     ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'

  belongs_to :section    ,:foreign_key=>:section_id        ,:class_name=>'Gwsub::Sb04section'
  belongs_to :job        ,:foreign_key=>:assignedjobs_id   ,:class_name=>'Gwsub::Sb04assignedjob'
  belongs_to :official   ,:foreign_key=>:official_title_id ,:class_name=>'Gwsub::Sb04officialtitle'

  validates_presence_of :section_id
  validates_presence_of :staff_no
  validates_presence_of :name

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def self.is_dev?(uid = Core.user.id)
    ret = System::Model::Role.get(1, uid ,'gwsub', 'developer')
    return ret
  end
  def self.is_admin?(uid = Core.user.id)
    ret = System::Model::Role.get(1, uid ,'sb04', 'admin')
    return ret
  end
  def self.is_editor?(org_code , g_code = Core.user_group.code)
    # get section name
    return false if org_code.blank?
    section = Gwsub::Sb04section.new
    section.code = org_code
    sections = section.find(:all)
    return false if sections.blank?
    section_name = sections[0].name
    # get group name
    group = System::GroupHistory.new
    group.code = g_code
    groups = group.find(:all)
    return false if groups.blank?
    group_name = groups[0].name
    # check name
    return false unless section_name.to_s == group_name.to_s
    return true
  end

  def self.duties_editable?(uid = Core.user.id , data=nil , u_role = false)
    # uid  : login user id
    # data : divide_duties top record on assigned job unit (担当ごとのトップレコード)
    #
    # editable_condition
    # (0) u_role == true (data administrator)
    return true   if u_role == true
    return false  if data.blank?
    u_cond = "user_id=#{uid} and end_at IS NULL"
    user_groups = System::UsersGroup.find(:all,:conditions=>u_cond)
    return false  if user_groups.blank?
    gcodes = []
    user_groups.each do |item|
        gcodes << item.group.code
    end
  return false if data.fyear_id.blank? || data.section_code.blank?
  section_cond = "fyear_id = #{data.fyear_id} and code = '#{data.section_code}'"
  section = Gwsub::Sb04section.find(:first,:conditions=>section_cond)
  return false  if section.blank?
    return false  if gcodes.index(section.ldap_code).blank?
    # (2) editable_dates:start_at <= today <= editable_dates:end_at
    today = Core.now
    dates_cond    = "fyear_id = #{data.fyear_id} and start_at <= '#{today}' and '#{today}' <= end_at"
    dates_order   = "start_at DESC"
    editable_dates = Gwsub::Sb04EditableDate.find(:first,:conditions=>dates_cond,:order=>dates_order)
    return false if editable_dates.blank?
    return true
  end
  def self.staff_select(u_role=false)
    # 表示対象データを、公開日の設定で絞り込む。
    # 管理者は、公開前でも確認可能
    markjp = ""
    if u_role == true
      find_order = "start_at DESC"
      find_year = Gwsub::Sb04EditableDate.find(:first,:order=>find_order)
      markjp = find_year.fyear_markjp if find_year.present?
    else
      today = Core.now
      find_cond = "published_at <='#{today}'"
      find_order = "start_at DESC"
      find_year = Gwsub::Sb04EditableDate.find(:first,:conditions=>find_cond,:order=>find_order)
      markjp = find_year.fyear_markjp if find_year.present?
    end
    str = "fyear_markjp <= '#{markjp}'"
    return str
  end

  def before_save_setting_columns
    if self.fyear_id.to_i==0
      before_save_setting_id
    else
      self.fyear_markjp               = self.fy_rel.markjp
      if self.section_id.to_i != 0 && !self.section.blank?
        self.section_code             = self.section.code
        self.section_name             = self.section.name
      else
        self.section_code             = nil
        self.section_name             = nil
      end
      if self.assignedjobs_id.to_i != 0 && !self.job.blank?
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
      if self.official_title_id.to_i != 0 && !self.official.blank?
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
    # 年度
    if self.fyear_id.blank?
      if self.fyear_markjp.blank?
        self.fyear_id = 0
      else
        # 年号から逆引き
        order = "start_at DESC"
        conditions = "markjp = '#{self.fyear_markjp}'"
        fyear = Gw::YearFiscalJp.find(:first,:conditions=>conditions,:order=>order)
        self.fyear_id = fyear.id
      end
    else
        fyear = Gw::YearFiscalJp.find_by_id(self.fyear_id.to_i)
        if fyear.blank?
          self.fyear_markjp = nil
        else
          self.fyear_markjp = fyear.markjp
        end
    end
    # 所属
    if self.section_id.blank?
      if self.section_code.blank?
        self.section_id   = 0
        self.section_name = nil
      else
        # コードから逆引き
        section = Gwsub::Sb04section.new
        section.fyear_id = self.fyear_id
        section.code = self.section_code
        section.order "fyear_markjp DESC , code ASC"
        sections = section.find(:all)
        self.section_id   = sections[0].id unless sections.blank?
        self.section_name = sections[0].name
      end
    else
        section = Gwsub::Sb04section.find_by_id(self.section_id.to_i)
        if section.blank?
          self.section_code = nil
          self.section_name = nil
        else
          self.section_code = section.code
          self.section_name = section.name
        end
    end
    # 担当
    if self.assignedjobs_id.blank?
      if self.assignedjobs_code.blank?
        self.assignedjobs_id        = 0
      else
        assignedjob   = Gwsub::Sb04assignedjob.new
        assignedjob.fyear_id = self.fyear_id
        assignedjob.code = self.assignedjobs_code
        assignedjob.order "fyear_markjp DESC , code ASC"
        assignedjobs  = assignedjob.find(:all)
        self.assignedjobs_id = assignedjobs[0].id unless assignedjobs.blank?
      end
    else
        job = Gwsub::Sb04assignedjob.find_by_id(self.assignedjobs_id.to_i)
        if job.blank?
          self.assignedjobs_id        = 0
          self.assignedjobs_code      = nil
          self.assignedjobs_code_int  = 0
          self.assignedjobs_name      = nil
          self.assignedjobs_tel       = nil
          self.assignedjobs_address   = nil
        else
          self.assignedjobs_id        = job.id
          self.assignedjobs_code      = job.code
          self.assignedjobs_code_int  = job.code.to_i
          self.assignedjobs_name      = job.name
          self.assignedjobs_tel       = job.tel
          self.assignedjobs_address   = job.address
        end
    end
    # 職名
    if self.official_title_id.blank?
      if self.official_title_code.blank?
        self.official_title_id = 0
      else
        official_title = Gwsub::Sb04officialtitle.new
        official_title.fyear_id = self.fyear_id
        official_title.code     = self.official_title_code
        official_title.order "fyear_markjp DESC , code ASC"
        official_titles = official_title.find(:all)
        self.official_title_id = official_titles[0].id unless official_titles.blank?
      end
    else
        official_title = official_title.find_by_id(self.official_title_id.to_i)
        if official_title.blank?
          self.official_title_code     = nil
          self.official_title_name     = nil
        else
          self.official_title_code     = official_title.code
          self.official_title_name     = official_title.name
        end
    end
  end
  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def stafflist_data_save(params, mode, options={})
    par_item = params[:item].dup

    if !par_item[:staff_no].blank? && par_item[:staff_no] !~ /^[0-9A-Za-z\_]+$/
      self.errors.add :staff_no, "は、半角英数字およびアンダーバー（_）で入力してください。"
    end

    if par_item[:fyear_id].blank?
      self.errors.add :fyear_id, "を入力してください。"
    else
      if !par_item[:multi_section_flg].blank? && par_item[:multi_section_flg].to_i == 1 # 本務の時、重複チェック
        if mode == :update
          item = self.find(:first,
            :conditions=>["staff_no = ? and fyear_id = ? and id != ? and multi_section_flg = 1", par_item[:staff_no],par_item[:fyear_id],self.id])
          self.errors.add :staff_no, "は、既に登録されています。" unless item.blank?
        elsif mode == :create
          item = self.find(:first,
            :conditions=>["staff_no = ? and fyear_id = ? and multi_section_flg = 1", par_item[:staff_no],par_item[:fyear_id]])
          self.errors.add :staff_no, "は、既に登録されています。" unless item.blank?
        end
      end
    end

    if !par_item[:divide_duties_order].blank? && par_item[:divide_duties_order] !~ /^[0-9]+$/
      self.errors.add :divide_duties_order, "は、半角数字で入力してください。"
    end

    self.attributes = par_item
    if mode == :update
      save_flg = self.errors.size == 0 && self.editable? && self.save()
    elsif mode == :create
      save_flg = self.errors.size == 0 && self.creatable? && self.save()
    end

    return save_flg
  end

  def self.multi_section_flg
    Gw.yaml_to_array_for_select 'gwsub_sb04stafflists_multi_sections_flg'
  end
  def self.multi_section_flg_show(flg)
    options={:rev=>true}
    flgs = Gw.yaml_to_array_for_select 'gwsub_sb04stafflists_multi_sections',options
#pp [flg,flgs]
    show_str = flgs.assoc(flg.to_s)
#pp show_str
    return nil if show_str.blank?
    return show_str[1]
  end

  def self.personal_state
    Gw.yaml_to_array_for_select 'gwsub_sb04_personal_state'
  end
  def self.duties_state
    Gw.yaml_to_array_for_select 'gwsub_sb04_duties_state'
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        # 所属・担当・職名・氏名・内線・備考・フリガナ・職員番号・事務分掌
        and_keywords2 v,:section_name,:assignedjobs_name,:official_title_name,:name,:extension,:remarks,:kana,:staff_no,:divide_duties
      when 'fyed_id'
        search_id v,:fyear_id   unless v.to_i == 0
      when 'grped_id'
        search_id v,:section_id unless v.to_i == 0
      when 'multi_section'
        search_keyword v,:multi_section_flg if v == '1'
      end
    end if params.size != 0

    return self
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gwsub_sb04stafflists` ;"
    connect.execute(truncate_query)
  end

  def self.stafflists_personal_state_show(personal_state)
    status = [[1,'する'],[2,'しない']]
    show_str = status.assoc(personal_state.to_i)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end
  def self.stafflists_display_state_show(display_state)
    status = [[1,'する'],[2,'しない']]
    show_str = status.assoc(display_state.to_i)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.year_copy_stafflists(par_item, auth = Hash::new)
    # 年度の違うデータをコピーする。
    ret = Hash::new
    msg = Array.new

    origin_fyear         = Gw::YearFiscalJp.find_by_id(par_item[:origin_fyear_id])
    destination_fyear    = Gw::YearFiscalJp.find_by_id(par_item[:destination_fyear_id])
    destination_section  = Gwsub::Sb04section.find_by_id(par_item[:destination_section_id])

    if origin_fyear.start_at >= destination_fyear.start_at
      ret[:result]    = false
      msg << ['エラー' ,"コピー元の年度が、コピー先の年度以降となっています。コピー元は、コピー先より前の年度を指定してください。"]
    end

    division_sb04_gids = Gwsub::Sb04stafflistviewMaster.get_division_sb04_gids
    if (division_sb04_gids.empty? || division_sb04_gids.index(par_item[:destination_section_id].to_i).blank?) && auth[:u_role] != true

      ret[:result]    = false
      msg << ['エラー' ,"コピー先の所属が、自所属もしくは主管課ではありません。コピー先は、自所属もしくは主管課を指定してください。"]
    end

    assignedjobs = Gwsub::Sb04assignedjob.find(:all, :conditions => ["fyear_id = ? and section_id = ?",
            par_item[:destination_fyear_id].to_i, par_item[:destination_section_id].to_i ])

    if assignedjobs.length == 0
      ret[:result]    = false
      msg << ['エラー' ,"コピー先の担当が存在しません。担当データのコピーを実施してください。"]
    end

    items = self.find(:all, :conditions => ["fyear_id = ? and section_id = ?", par_item[:origin_fyear_id].to_i, par_item[:origin_section_id].to_i ],
      :order => 'id')
    if items.blank?
      ret[:result]    = false
      msg << ['エラー' ,"コピー元の職員データが存在しません。コピー元の選択を変更してください。"]
    end

    if ret[:result] == false
      ret[:msg] = msg
      return ret
    else
      # コピー先所属を削除
      self.destroy_all(["fyear_id = ? and section_id = ?", par_item[:destination_fyear_id].to_i, par_item[:destination_section_id].to_i ])
      # コピー
      fields = Array.new
      items = self.find(:all, :conditions => ["fyear_id = ? and section_id = ?", par_item[:origin_fyear_id].to_i, par_item[:origin_section_id].to_i ],
        :order => 'id')

      self.columns.each do |column|
        fields << "#{column.name}"
      end

      save_cnt = items.length
      items.each_with_index do |item, i|
        # 担当
        assignedjob = Gwsub::Sb04assignedjob.find(:first, :conditions => ["fyear_id = ? and section_id = ? and code_int = ?",
            par_item[:destination_fyear_id].to_i, par_item[:destination_section_id].to_i, item.assignedjobs_code_int ])
        # 職名
        officialtitle = Gwsub::Sb04officialtitle.find(:first, :conditions => ["fyear_id = ? and name = ?",
            par_item[:destination_fyear_id].to_i, item.official_title_name ])

        model = self.new
        model.class.before_save.clear # コールバックをフックして無効化する。
        fields.each do |field|
          case field.to_s
          when 'id', 'updated_user', 'updated_group', 'created_user', 'created_group' # id等はコピーしない
          when 'fyear_id'
            model.fyear_id     = destination_fyear.id
          when 'fyear_markjp'
            model.fyear_markjp = destination_fyear.markjp
          when 'section_id' # 所属
            model.section_id   = destination_section.id
          when 'section_code'
            model.section_code = destination_section.code
          when 'section_name'
            model.section_name = destination_section.name
          when 'assignedjobs_id' # 担当
            model.assignedjobs_id   = assignedjob.id unless assignedjob.blank?
          when 'assignedjobs_code_int'
            model.assignedjobs_code_int = assignedjob.code_int unless assignedjob.blank?
          when 'assignedjobs_code'
            model.assignedjobs_code = assignedjob.code unless assignedjob.blank?
          when 'assignedjobs_name'
            model.assignedjobs_name = assignedjob.name unless assignedjob.blank?
          when 'assignedjobs_tel'
            model.assignedjobs_tel = assignedjob.tel unless assignedjob.blank?
          when 'assignedjobs_address'
            model.assignedjobs_address = assignedjob.address unless assignedjob.blank?
          when 'official_title_id' # 職名
            model.official_title_id   = officialtitle.id unless officialtitle.blank?
          when 'official_title_code'
            model.official_title_code = officialtitle.code unless officialtitle.blank?
          when 'official_title_code_int'
            model.official_title_code_int = officialtitle.code_int unless officialtitle.blank?
          when 'official_title_name'
            model.official_title_name = officialtitle.name unless officialtitle.blank?
          when 'created_at'
            model.created_at   = Time.now
          when 'updated_at'
            model.updated_at   = Time.now
          else
            eval("model.#{field} = nz(item.#{field}, nil)")
          end
        end
        model.save(:validate=>false)
      end
      origin_fyear         = Gw::YearFiscalJp.find_by_id(par_item[:origin_fyear_id])
      destination_fyear    = Gw::YearFiscalJp.find_by_id(par_item[:destination_fyear_id])
      destination_section  = Gwsub::Sb04section.find_by_id(par_item[:destination_section_id])

      Gwsub::Sb04YearCopyLog.create_log('stafflist',
        par_item[:origin_fyear_id], par_item[:origin_section_id], par_item[:destination_fyear_id], par_item[:destination_section_id])
      ret[:result]    = true
      msg << "#{save_cnt}件のデータをコピーしました。"
      ret[:msg] = msg
      return ret
    end

  end
end
