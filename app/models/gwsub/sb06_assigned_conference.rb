class Gwsub::Sb06AssignedConference < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  include Gwsub::Model::Recognition

  belongs_to :grp1         ,:foreign_key=>:group_id            ,:class_name => 'System::GroupHistory'
  belongs_to :grp2         ,:foreign_key=>:user_section_id     ,:class_name => 'System::GroupHistory'
  belongs_to :grp3         ,:foreign_key=>:main_group_id       ,:class_name => 'System::GroupHistory'
  belongs_to :user1        ,:foreign_key=>:user_id             ,:class_name => 'System::User'
  belongs_to :fy1          ,:foreign_key=>:fyear_id            ,:class_name => 'Gw::YearFiscalJp'
  belongs_to :c_cat        ,:foreign_key=>:categories_id       ,:class_name => 'Gwsub::Sb06AssignedConfCategory'
  belongs_to :c_grp        ,:foreign_key=>:conf_group_id       ,:class_name => 'Gwsub::Sb06AssignedConfGroup'
  belongs_to :c_kind       ,:foreign_key=>:conf_kind_id        ,:class_name => 'Gwsub::Sb06AssignedConfKind'
  belongs_to :c_item       ,:foreign_key=>:conf_item_id        ,:class_name => 'Gwsub::Sb06AssignedConfItem'
  belongs_to :c_item_sub   ,:foreign_key=>:conf_item_sub_id    ,:class_name => 'Gwsub::Sb06AssignedConfItemSub'
  belongs_to :o_title1     ,:foreign_key=>:official_title_id   ,:class_name => 'Gwsub::Sb06AssignedOfficialTitle'
  belongs_to :a_group      ,:foreign_key=>:admin_group_id      ,:class_name=>'System::Group'

  has_many :conf_member ,:foreign_key=>:conference_id  ,:class_name=>'Gwsub::Sb06AssignedConferenceMember' , :dependent=>:destroy

  after_save :save_recognizers

  validates_presence_of :conf_at,:group_id   , :unless=>Proc.new{|item| item.state.to_i==1}
  validates_presence_of :conf_kind_place     , :unless=>Proc.new{|item| item.state.to_i==1 or !(item.c_kind.conf_kind_code=='302') }
  validate :validate_conf_mark
  validate :validate_conf_no
#  validates_presence_of :conf_at,:group_id,:user_id
#  validates_presence_of :conf_at,:group_id,:official_title_id,:user_id
#  validates_uniqueness_of :user_id, :scope => [:fyear_id , :conf_kind_id , :group_id , :conf_kind_place , :conf_item_id ] ,:message=>'は、登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('sb0602/admin')
  end

  def self.editable_data(item,options={})
    # 管理者は常時編集可能
    if options[:role]==true
      return true
    end
    # 主管課ユーザーは管理者
    if Gwsub::Sb06AssignedConference.managers?(item,options)
      return true
    end
    # 一般は自所属のみ編集可能 (承認依頼前のみ編集可能)
    if options[:group_id]
      group_id = options[:group_id]
    else
      group_id = Core.user_group.id
    end
    if item.group_id == group_id
      if item.state.to_i==1
        return true
      else
        return false
      end
    else
      return false
    end
  end
  def self.managers?(item,options={})
    # データの管理者判定
    # システム管理者
    if options[:role]==true
      return true
    end
    # 主管所属のユーザーが管理者
    if options[:group_id]
      group_id = options[:group_id]
    else
      group_id = Core.user_group.id
    end
    conf_group =  Gwsub::Sb06AssignedConfGroup.new
    conf_group.categories_id  = item.categories_id
    conf_group.fyear_id       = item.fyear_id
    conf_group.group_id       = group_id
    conf_group.order "fyear_markjp DESC , group_code"
    conf_groups = conf_group.find(:all)
    if conf_groups.blank?
      return false
    else
      return true
    end
    return false
  end
  def self.recognizer(item,options={})
    # 管理者は常時承認可能
    if options[:role]==true
      return true
    end
    # TODO 一般は指名者のみ承認可能
    if options[:group_id]
      group_id = options[:group_id]
    else
      group_id = Core.user_group.id
    end
    if item.group_id == group_id
      return true
    else
      return false
    end
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
#    self.created_user_id= Core.user.id  unless self.created_user_id
#    self.updated_user_id= Core.user.id  unless self.updated_user_id
    self.created_user_id= Core.user.id
    self.updated_user_id= Core.user.id
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
#    self.updated_user_id= Core.user.id  unless self.updated_user_id
    self.updated_user_id= Core.user.id
  end

  def before_save_setting_columns
    # id=>code/name
    # 年度
    unless self.fyear_id.to_i==0
      self.fyear_markjp = self.fy1.markjp
      self.fyear_namejp = self.fy1.namejp
    end
    # 分類
    unless self.categories_id.to_i==0
      self.cat_sort_no  = self.c_cat.cat_sort_no
      self.cat_code     = self.c_cat.cat_code
      self.cat_name     = self.c_cat.cat_name
    end
    # 申請書種別
    unless self.conf_kind_id.to_i==0
#      self.conf_group_id      = self.c_kind.conf_group_id
      self.conf_kind_sort_no  = self.c_kind.conf_kind_sort_no
      self.conf_kind_name     = self.c_kind.conf_kind_name
      conf_group = Gwsub::Sb06AssignedConfGroup.new
      conf_group.fyear_id = self.fyear_id
      conf_group.categories_id = self.categories_id
      conf_groups = conf_group.find(:all)
      if conf_groups.blank?
        self.conf_group_id      = 0
      else
        self.conf_group_id      = conf_groups[0].id
      end
    end
    # 管理所属
    unless self.conf_group_id.to_i==0
      self.conf_group_code = self.c_grp.group_code
      self.conf_group_name = self.c_grp.group_name
    end
    #記事管理課
    if self.admin_group_id.to_i!=0 && !a_group.blank?
      self.admin_group_code = self.a_group.code
      self.admin_group_name = self.a_group.name
    end
    # 申請所属
    unless self.group_id.to_i==0
      # 管理者権限がなければ、自所属のみ表示
      item = Gwsub::Sb00ConferenceSectionManagerName.new
      item.and :state, 'enabled'
      item.and :fyear_id, self.fyear_id
      item.and :id, self.section_manager_id
      grp1 = item.find(:first)
      self.group_code = grp1.g_code unless grp1.blank?
      self.group_name = grp1.manager_name unless grp1.blank?
      self.group_name_display = grp1.g_code + grp1.manager_name unless grp1.blank?
    end
    # 申請書項目
    unless self.conf_item_id.to_i==0
      self.conf_item_sort_no = self.c_item.item_sort_no
      self.conf_item_title   = self.c_item.item_title
    end
    # 担当者
    unless self.user_id.to_i==0
#      self.user_code     = self.user.code
      self.user_name     = self.user1.name
    end
    # 職
#    unless self.official_title_id.to_i==0
#      self.official_title_name    = self.o_title1.official_title_name
#    end
    # 担当者所属
    unless self.user_section_id.to_i==0
      self.user_section_name    = self.grp2.name    unless self.grp2.blank?
      self.user_section_sort_no = self.grp2.sort_no unless self.grp2.blank?
    end
    # 取りまとめ担当所属
    unless self.main_group_id.to_i==0
      self.main_group_name    = self.grp3.name    unless self.grp3.blank?
      self.main_group_sort_no = self.grp3.sort_no unless self.grp3.blank?
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:extension,:user_mail,:user_job_name
      when 'c_state'
        search_id v,:state unless v.to_i==0
      when 'c_cat_id'
        search_id v,:categories_id unless v.to_i==0
      when 'fy_id'
        search_id v,:fyear_id unless v.to_i==0
#      when 'c_group_id'
#        search_id v,:conf_group_id unless v.to_i==0
      when 'kind_id'
        search_id v,:conf_kind_id unless v.to_i==0
      when 'group_id'
        #search_id v,:group_id unless v.to_i==0
        search_id v,:admin_group_id unless v.to_i==0
#      when 'user_id'
#        search_id v,:user_id unless v.to_i==0
      end
    end if params.size != 0

    return self
  end

  def self.proposal_status
    Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conferences_state'
  end
  def self.assigned_status_602
    Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conferences_state_602'
  end

  def self.conference_states(option)
    all = nil
    all = option[:all]
    options = {:rev=>false}
    status1 = Gw.yaml_to_array_for_select('gwsub_sb06_assigned_conferences_state2',options)
    if all=='all'
      status  = [['すべて',0]]+status1
    else
      status  = status1
    end
    return status
  end
  def self.conference_state_show(state)
    options = {:rev=>true}
    status = Gw.yaml_to_array_for_select('gwsub_sb06_assigned_conferences_state2',options)
    show  = status.assoc(state.to_i)
    return nil      if show.blank?
    return show[1]  unless show.blank?
  end

  def validate_conf_mark
   valid  = true
   form_no = self.c_kind.conf_form_no
   if self.state.to_i == 4
    case form_no
    when "301","302","303","401","602"
      if self.conf_mark.blank?
        errors.add :conf_mark, 'を入力してください。'
        valid = false
        return valid
      end
    else
    end
   end
  end

  def validate_conf_no
   valid  = true
   form_no = self.c_kind.conf_form_no
   if self.state.to_i == 4
    case form_no
    when "301","302","303","401","602"
      if self.conf_no.blank?
        errors.add :conf_no, 'を入力してください。'
        valid = false
        return valid
      end
    else
    end
   end
  end
  #--------承認関係↓---------
  #リマインダー通知：担当者→承認者
  def save_recognizers
    # 承認中以外はスキップ
    unless self.state.to_i == 2
      return
    end
    # 承認中の時は、承認者を登録して連絡メモを送付
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conf_addmemo',options
    d_state = state[0][1]#1: 承認依頼が通知されました。
    s_state = state[1][1]#2: 内容を確認し、承認処理を行ってください。
    kind_name= self.c_kind.conf_kind_name
    self._recognizers.each do |k, v|
      unless v.to_s == ''
        Gwsub::Sb06Recognizer.create(
          :mode =>  1 ,
          :parent_id => self.id,
          :user_id => v.to_s
        )
        Gw.add_memo(v.to_s, "#{kind_name}の"+"#{d_state}","#{s_state}<br /><a href='/gwsub/sb06/sb06_assigned_conferences/#{self.id}'><img src='/_common/themes/gw/files/bt_approvalconfirm.gif' alt='承認処理へ'></a>")
      end
    end unless self._recognizers.blank?
  end

   #リマインダー通知：承認者→担当者
  def rec_rejected
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conf_addmemo',options
    d_state = state[2][1]#3:承認依頼が却下されました。
    s_state = state[3][1]#4:内容を修正し、再度承認依頼を行ってください。
    kind_name= self.c_kind.conf_kind_name#
#    v = self.updated_user_id
    v = self.created_user_id
    Gw.add_memo(v.to_s, "#{kind_name}の"+"#{d_state}","<a href='/gwsub/sb06/sb06_assigned_conferences/#{self.id}'>#{s_state}</a>")
  end

  def rec_comp
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conf_addmemo',options
    d_state = state[4][1]
    s_state = state[5][1]
    kind_name= self.c_kind.conf_kind_name#
#    v = self.updated_user_id
    v = self.created_user_id
    Gw.add_memo(v.to_s, "#{kind_name}の"+"#{d_state}","<a href='/gwsub/sb06/sb06_assigned_conferences/#{self.id}/edit_docno'>#{s_state}</a>")
  end


  def item_no_import
    options = {:rev => true}
    state = Gw.yaml_to_array_for_select 'gwsub_sb06_assigned_conf_addmemo',options
    d_state = state[4][1]#3:承認依頼が却下されました。
    s_state = state[5][1]#4:内容を修正し、再度承認依頼を行ってください。
    kind_name= self.c_kind.conf_kind_name#
#    v = self.updated_user_id
    v = self.created_user_id
    Gw.add_memo(v.to_s, "#{kind_name}の"+"#{d_state}","<a href='/gwsub/sb06/sb06_assigned_conferences/#{self.id}/item_no_form'>#{s_state}</a>")
  end
    #申請書に対して承認者全員分を検索
  def recognize_all
    item = Gwsub::Sb06Recognizer.new
    item.and :mode,1
    item.and :parent_id, self.id
    return item.find(:all)
  end

    #state==2(承認中状態)で承認者が一人でもセレクトされているかをチェック。それ以外はノーチェック。
  def validate_recognizers
    if self.state =='2'
      check_validate_recognizers  if  _recognizers
    end
  end

end
