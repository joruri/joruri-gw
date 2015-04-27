class Gwsub::Sb06AssignedConferenceMember < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
#  include Gwsub::Model::Recognition

  belongs_to :c_conference ,:foreign_key=>:conference_id       ,:class_name => 'Gwsub::Sb06AssignedConference'
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

#  after_save :save_recognizers

#  validates_presence_of :conf_at,:group_id,:user_id ,:unless=>Proc.new{|item| item.conf_item_id.to_i==0}
#  validates_uniqueness_of :user_id, :scope => [:fyear_id , :conf_kind_id , :group_id , :conf_kind_place , :conf_item_id ] \
#    ,:message=>'は、登録済です。' ,:unless=>Proc.new{|item| item.conf_item_id.to_i==0}

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
    self.created_user_id= Core.user.id
    self.updated_user_id= Core.user.id
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
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
    # 申請所属
    unless self.group_id.to_i==0
      self.group_code         = self.grp1.code
      self.group_name         = self.grp1.name
      self.group_name_display = self.grp1.code + self.grp1.name
    end
    # 申請書項目
    unless self.conf_item_id.to_i==0
      self.conf_item_sort_no = self.c_item.item_sort_no
      self.conf_item_title   = self.c_item.item_title
    end
    # 担当者
    if self.user_id.to_i > 0
#      self.user_code     = self.user.code
      self.user_name     = self.user1.name
      if self.conf_kind_sort_no.to_i == 401
        # メールアドレスを追加で設定
        self.user_mail  = self.user1.email
      end
    end
    # 職
#    unless self.official_title_id.to_i==0
#      self.official_title_name    = self.o_title1.official_title_name
#    end
    # 職名はテキスト入力に変更
    #
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
        search_id v,:group_id unless v.to_i==0
#      when 'user_id'
#        search_id v,:user_id unless v.to_i==0
      end
    end if params.size != 0

    return self
  end
end
