class Gwsub::Sb06BudgetRole < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

#  has_many :staffs      ,:foreign_key=>:assignedjobs_id  ,:class_name=>'Gwsub::Sb04stafflist'

  validates_presence_of :code,:name
  validates_uniqueness_of :code,:name

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('sb0601/admin')
  end

  def self.budget_admin?(uid = Core.user.id)
    # 予算担当　管理者権限
    b_admin_cond  = "user_id=#{uid}"
    b_admin = Gwsub::Sb06BudgetAssignAdmin.where(b_admin_cond)
    # 予算担当管理者に登録済か？
    if b_admin.blank?
      # 予算担当管理者未登録
      return false
    end
    return true
  end
  def self.budget_main?(uid = Core.user.id)
    # 予算担当　主管課権限
    b_main_cond  = "user_id=#{uid}"
    b_main = Gwsub::Sb06BudgetAssignMain.where(b_main_cond)
    # 予算担当主管課に登録済か？
    if b_main.blank?
      # 予算担当管理者未登録
      return false
    end
    return true
  end

  def self.budget_editable?(uid = Core.user.id , date = Time.now , data = nil)
    # 予算担当　登録・編集権限
    # 管理者は期間無制限で編集可能
    role_admin = Gwsub::Sb06BudgetRole.budget_admin?(uid)
    return true if role_admin == true

    # data上のedit_state チェックは削除 (編集権限セットは削除)
    # return true if data.edit_state==true

    # 主管課・一般は、期間制限あり
    date_range = Gwsub::Sb06BudgetEditableDate.order("start_at DESC")
    # 制限期間未登録時は編集不可
    return false if date_range.blank?
    if date_range[0].start_at <= date && date <= date_range[0].end_at
      # 編集期間内であれば、編集可能
      return true
    else
      # 編集期間外であれば、編集不可
      return false
    end
  end
  def self.budget_recognizable?(type='main',uid = Core.user.id , date = Time.now , data = nil)
    # 予算担当　承認権限
    case type
    when 'admin'
      # 管理者承認は管理者であれば、期間無制限で承認可能
      role_admin  = Gwsub::Sb06BudgetRole.budget_admin?(uid)
      if role_admin == true
        return true
      else
        return false
      end
    when 'main'
      # 主管課承認
      # 管理者であれば、期間無制限で承認可能
      role_admin  = Gwsub::Sb06BudgetRole.budget_admin?(uid)
      return true if role_admin == true
      # 主管課ユーザー以外は不可
      role_main   = Gwsub::Sb06BudgetRole.budget_main?(uid)
      return false unless role_main == true
      # 主管課承認は、期限あり
      date_range = Gwsub::Sb06BudgetEditableDate.order("start_at DESC")
      # 制限期間未登録時は承認不可
      return false if date_range.blank?
      return false if date_range[0].recognize_at.blank?
      if date <= date_range[0].recognize_at
        # 承認期限前であれば、承認可能
        return true
      else
        # 承認期限後であれば、承認不可
        return false
      end
    else
      return false
    end
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb06_budget_roles_id_select(all=nil)
    order = "code ASC"
    select = "id,code,name"
#    level=6
#    level=4 if Gwsub::Sb06BudgetRole.budget_main? == true
#    level=1 if Gwsub::Sb06BudgetRole.budget_admin? == true
    item = Gwsub::Sb06BudgetRole.new
#    role_cond = "code >= '#{level}'"
#    items = item.find(:all,:select=>select,:order=>order,:conditions=>role_cond)
    items = item.find(:all,:select=>select,:order=>order)
    selects = []
    selects << ['すべて','0'] if all=='all'
    items.each do |g|
      selects << ['('+g.code+') '+g.name ,g.id]
    end
    return selects
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:code,:name
      end
    end if params.size != 0

    return self
  end
end
