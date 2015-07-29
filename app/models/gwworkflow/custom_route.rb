# -*- encoding: utf-8 -*-

class Gwworkflow::CustomRoute < Gw::Database
  set_table_name 'gw_workflow_custom_routes'
  
  has_many :steps, :class_name => 'Gwworkflow::CustomRouteStep', :foreign_key => :custom_route_id,
    :dependent => :destroy

  validates :sort_no, :presence => true, :numericality => {:only_integer => true}, :inclusion => { in: 0..9999 }
  validates :name, :presence => true
  validates :state, :presence => true
  
  validate :committees_valid?
  def committees_valid?
    errors.add('承認ステップ', 'を少なくとも1つ設定してください。') if steps.length == 0
  end
  
  def creater_id
    owner_uid
  end
  
  def enabled?
    state == 'enabled'
  end

  def sorted_steps
    steps.sort{|a,b|a.number <=> b.number}
  end
  
  def total_steps
    steps.length
  end
  
  def current_step
    nil
  end
  
  def fixed_steps
    []
  end
  
  def future_steps
    sorted_steps
  end
  
  def fixed_committees
    fixed_steps.map{|step| step.committee }
  end
  
  def future_committees
    future_steps.map{|step| step.committee }
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

end
