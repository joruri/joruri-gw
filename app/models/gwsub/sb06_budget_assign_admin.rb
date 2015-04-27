class Gwsub::Sb06BudgetAssignAdmin < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :grp1        ,:foreign_key=>:group_id                ,:class_name => 'System::GroupHistory'
  belongs_to :grp2        ,:foreign_key=>:multi_group_id          ,:class_name => 'System::GroupHistory'
  belongs_to :grp_p1      ,:foreign_key=>:group_parent_id         ,:class_name => 'System::GroupHistory'
  belongs_to :grp_p2      ,:foreign_key=>:multi_group_parent_id   ,:class_name => 'System::GroupHistory'
  belongs_to :user        ,:foreign_key=>:user_id                 ,:class_name => 'System::User'
  belongs_to :b_role      ,:foreign_key=>:budget_role_id          ,:class_name => 'Gwsub::Sb06BudgetRole'

  validates_presence_of   :group_id,:user_id
  validates_uniqueness_of :user_id ,:message=>'に登録済です。'

  before_validation :before_validates_setting_columns
  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
#  before_save :before_save_setting_columns
  after_save :after_save_create_budget_assign_records

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def before_validates_setting_columns
#  def before_save_setting_columns
    self.multi_sequence   =   ''
    # id=>code/name
    unless self.group_id.to_i==0
      self.group_code       = self.grp1.code
      self.group_name       = self.grp1.name
      self.group_ou         = self.group_code+self.group_name
      self.multi_group_id   = self.group_id
      self.multi_group_code = self.grp1.code
      self.multi_group_name = self.grp1.name
      self.multi_group_ou   = self.group_code+self.group_name
      if self.group_parent_id.to_i==0
        self.group_parent_id          = self.grp1.parent_id
        self.group_parent_code        = self.grp_p1.code
        self.group_parent_name        = self.grp_p1.name
        self.group_parent_ou          = self.group_parent_code + self.group_parent_name
        self.multi_group_parent_id    = self.group_parent_id
        self.multi_group_parent_code  = self.grp_p1.code
        self.multi_group_parent_name  = self.grp_p1.name
        self.multi_group_parent_ou    = self.group_parent_code + self.group_parent_name
      else
        self.group_parent_code        = self.grp_p1.code
        self.group_parent_name        = self.grp_p1.name
        self.group_parent_ou          = self.group_parent_code + self.group_parent_name
        self.multi_group_parent_id    = self.group_parent_id
        self.multi_group_parent_code  = self.grp_p1.code
        self.multi_group_parent_name  = self.grp_p1.name
        self.multi_group_parent_ou    = self.group_parent_code + self.group_parent_name
      end
    end
    unless self.user_id.to_i==0
      self.user_code          = self.user.code
      self.user_name          = self.user.name
      self.multi_user_code    = self.user_code
    end
    unless self.budget_role_id.to_i==0
      self.budget_role_code    = self.b_role.code
      self.budget_role_name    = self.b_role.name
    end
    self.main_state   ='1'
    self.admin_state  ='1'
  end

  def after_save_create_budget_assign_records
    # ユーザーと権限でチェックし、登録済の場合は上書き
    budget_assign_admin1                 = Gwsub::Sb06BudgetAssign.new
    budget_assign_admin1.multi_user_code = self.multi_user_code
    budget_assign_admin1.budget_role_id  = self.budget_role_id
    budget_assign_admin1.order  "multi_user_code , budget_role_id"
    budget_assign_admin                  = budget_assign_admin1.find(:first)
    if budget_assign_admin.blank?
      budget_assign_admin = Gwsub::Sb06BudgetAssign.new
    end
    # 管理者登録ができたら予算担当レコードを作成・上書き
    budget_assign_admin.group_parent_id           = self.group_parent_id
    budget_assign_admin.group_parent_ou           = self.group_parent_ou
    budget_assign_admin.group_parent_code         = self.group_parent_code
    budget_assign_admin.group_parent_name         = self.group_parent_name
    budget_assign_admin.group_id                  = self.group_id
    budget_assign_admin.group_ou                  = self.group_ou
    budget_assign_admin.group_code                = self.group_code
    budget_assign_admin.group_name                = self.group_name
    budget_assign_admin.multi_group_parent_id     = self.group_parent_id
    budget_assign_admin.multi_group_parent_ou     = self.group_parent_ou
    budget_assign_admin.multi_group_parent_code   = self.group_parent_code
    budget_assign_admin.multi_group_parent_name   = self.group_parent_name
    budget_assign_admin.multi_group_id            = self.group_id
    budget_assign_admin.multi_group_ou            = self.group_ou
    budget_assign_admin.multi_group_code          = self.group_code
    budget_assign_admin.multi_group_name          = self.group_name
    budget_assign_admin.multi_sequence            = self.multi_sequence
    budget_assign_admin.multi_user_code           = self.multi_user_code
    budget_assign_admin.user_id                   = self.user_id
    budget_assign_admin.user_code                 = self.user_code
    budget_assign_admin.user_name                 = self.user_name
    budget_assign_admin.budget_role_id            = self.budget_role_id
    budget_assign_admin.budget_role_code          = self.budget_role_code
    budget_assign_admin.budget_role_name          = self.budget_role_name
    budget_assign_admin.admin_state               = self.admin_state
    budget_assign_admin.main_state                = self.main_state
    budget_assign_admin.save(:validate => false)
  end

  def self.admin_state(all=nil)
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_assigns_admin'
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.admin_state_show(state)
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_assigns_admin'
    state_show = []
    states.each do |value,key|
      state_show << [key,value]
    end
    show = state_show.assoc(state.to_i)
    return show[1] unless show.blank?
    return nil     if     show.blank?
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:group_code,:group_name,:user_code,:user_name,:multi_group_code,:multi_group_name,:budget_role_name
      when 'b_role_id'
        search_id v,:budget_role_id unless v.to_i==0
      when 'group_parent_id'
        search_id v,:group_parent_id unless v.to_i==0
      when 'group_id'
        search_id v,:group_id unless v.to_i==0
      when 'multi_group_id'
        search_id v,:multi_group_id unless v.to_i==0
      when 'm_state'
        search_id v,:main_state unless v.to_i==0
      when 'a_state'
        search_id v,:admin_state unless v.to_i==0
      end
    end if params.size != 0

    return self
  end
end
