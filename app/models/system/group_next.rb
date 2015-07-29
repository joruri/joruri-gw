# encoding: utf-8
class System::GroupNext < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Tree
  include System::Model::Base::Config

  belongs_to   :group_update , :foreign_key => :group_update_id  , :class_name => 'System::GroupUpdate'
  belongs_to   :old_g        , :foreign_key => :old_group_id     , :class_name => 'System::Group'

  validates_uniqueness_of :old_group_id ,:message=>"は、すでに割当済です。"

  before_save :before_save_set_column

  def before_save_set_column
    if self.old_group_id.to_i== 0
    else
      self.old_parent_id = self.old_g.parent_id
      self.old_name = self.old_g.name
      self.old_code = self.old_g.code
    end
  end

  def self.state(all=nil)
    states = Gw.yaml_to_array_for_select 'system_group_nexts_state'
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.state_show(state)
    options = {:rev=>true}
    states = Gw.yaml_to_array_for_select( 'system_group_nexts_state',options)
    show_value = states.assoc(state.to_i)
    return nil if show_value.blank?
    return show_value[1]
  end
  def self.convert_state(state)
    options = {:rev=>false}
    states = Gw.yaml_to_array_for_select( 'system_group_nexts_state',options)
    show_value = states.assoc(state)
    return nil if show_value.blank?
    return show_value[1]
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `system_group_nexts` ;"
    connect.execute(truncate_query)
  end
end
