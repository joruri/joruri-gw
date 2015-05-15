class Gwworkflow::Step < Gw::Database
  self.table_name = 'gw_workflow_route_steps'

  has_many :committees, :class_name => 'Gwworkflow::Committee', :foreign_key => :step_id, :dependent => :destroy
  belongs_to :doc, :class_name => 'Gwworkflow::Doc', :foreign_key => :doc_id

  accepts_nested_attributes_for :committees, allow_destroy: true

  def accepted?(options = {})
    committees.all?{|c| c.state.to_sym == :accepted}
  end

  def rejected?(options = {})
    committees.any?{|c| c.state.to_sym == :rejected}
  end

  def remanded?(options = {})
    committees.any?{|c| c.state.to_sym == :remanded}
  end

  def state(options = {})
    return :rejected if rejected?(options)
    return :remanded if remanded?(options)
    return :accepted if accepted?(options)
    return :processing
  end

  def committee
    committees.first
  end
end
