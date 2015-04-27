class Gwsub::Sb06BudgetNotice < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :title
  validates_presence_of :bbs_url

#  before_save :before_save_setting_columns
  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.help_kind(all=nil)
    options = {:rev=>false}
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_notices_kind',options
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.help_kind_show(state)
    options = {:rev=>true}
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_notices_kind',options
    show = states.assoc(state.to_i)
    return show[1] unless show.blank?
    return nil     if     show.blank?
  end
  def self.help_state(all=nil)
    options = {:rev=>false}
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_notices_state',options
    states = [['すべて','0']] + states if all=='all'
    return states
  end
  def self.help_state_show(state)
    options = {:rev=>true}
    states = Gw.yaml_to_array_for_select 'gwsub_sb06_budget_notices_state',options
    show = states.assoc(state.to_i)
    return show[1] unless show.blank?
    return nil     if     show.blank?
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:title,:bbs_url,:remarks
      end
    end if params.size != 0

    return self
  end
end
