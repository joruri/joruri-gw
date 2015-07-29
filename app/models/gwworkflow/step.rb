# -*- encoding: utf-8 -*-

# 対象データベースは ****_jgw_gw なので Gw::Database を継承
class Gwworkflow::Step < Gw::Database
  # テーブル名を明示的に指定
  set_table_name 'gw_workflow_route_steps'
  
  belongs_to :doc, :class_name => 'Gwworkflow::Doc', :foreign_key => :doc_id,
    :autosave =>true, :touch => true
  
  has_many :committees, :class_name => 'Gwworkflow::Committee', :foreign_key => :step_id,
    :dependent => :destroy
  
  #validates :number, :presence => true
  
  def accepted? options={}
    committees.all?{|c| c.state.to_sym == :accepted}
  end
  
  def rejected? options={}
    committees.any?{|c| c.state.to_sym == :rejected}
  end
  
  def remanded? options={}
    committees.any?{|c| c.state.to_sym == :remanded}
  end

  def state options={}
    return :rejected if rejected? options
    return :remanded if remanded? options
    return :accepted if accepted? options
    return :processing
  end
  
  def committee
    (committees && committees.length > 0) ? committees.first : nil
  end

end
