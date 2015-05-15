class Gwworkflow::Committee < Gw::Database
  self.table_name = 'gw_workflow_route_users'

  belongs_to :step, :class_name => 'Gwworkflow::Step', :foreign_key => :step_id,
    :autosave => true, :touch => true
  belongs_to :user, :class_name => 'System::User', :foreign_key => :user_id

  #validates :state, :presence => true

  def state_str
    case state.to_sym
    when :accepted then '承認'
    when :remanded then '差し戻し'
    when :rejected then '却下'
    else
      (step && step.doc.current_step && step.doc.current_step.committee.id) == id ? '処理中' : ''
    end
  end

  def user_name_and_code
    user.try(:name_and_code)
  end

  def user_enable?
    user && user.state == 'enabled'
 end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  # 条件を指定して取得
  def self.find_by_conditions options={}
    uid = options[:user_id] || -1
    sid = options[:step_id] || -1
    cnd = arel_table[:user_id].eq(uid)
    cnd = cnd.and(arel_table[:step_id].eq(sid))
    where(cnd).first
  end
end
