class Gwsub::Sb06AssignedConfCategory < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  has_many :c_grp   ,:foreign_key=>:categories_id ,:class_name => 'Gwsub::Sb06AssignedConfGroup'

  validates_presence_of :cat_code,:cat_name,:cat_sort_no
  validates_uniqueness_of :cat_code ,:message=>'は登録済です。'
  validates_uniqueness_of :cat_name ,:message=>'は登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb06_assign_conf_cat_id_select(options={})
    # options
    # :code   1:選択肢にコードを付加
    # :all    選択肢の先頭に「すべて」を表示
    all   = nil
    code  = nil
    all   = options[:all]   if ( !options.blank? and options.has_key?(:all)   ==true )
    code  = options[:code]  if ( !options.blank? and options.has_key?(:code)  ==true )
    order = "cat_sort_no ASC"
    item = Gwsub::Sb06AssignedConfCategory.new
#    items = item.find(:all,:order=>order)
    items = item.find(:all,:order=>order,:conditions=>"select_list='1'")
    selects = []
    selects << ['すべて',0] if all=='all'
    items.each do |g|
      selects << [g.cat_name ,g.id]                     unless  code.to_i==1
      selects << ['('+g.cat_code+')'+g.cat_name ,g.id]  if      code.to_i==1
    end
    return selects
  end
  def self.sb06_assign_conf_cat_get(options={})
    order = "cat_sort_no ASC"
    item = Gwsub::Sb06AssignedConfCategory.new
#    items = item.find(:all,:order=>order)
    items = item.find(:all,:order=>order,:conditions=>"select_list='1'")
    return items
  end

  def self.select_list_status(all=nil)
#    { 1 => '表示する' , 0 => '表示しない'}
    states      =  Gw.yaml_to_array_for_select 'gwsub_sb06_master_code_select_list'
    states      = [['all',0]] + states if all=='all'
    state_list  = states unless all=='all'
    return state_list
  end
  def self.select_list_show(state)
#    { 1 => '表示する' , 0 => '表示しない'}
    options     = {:rev => true}
    states      =  Gw.yaml_to_array_for_select 'gwsub_sb06_master_code_select_list',options
    state_show  = states.assoc(state)
    if      state_show.blank?
      return nil
    else
      return state_show[1]
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:cat_code,:cat_name
      end if params.size != 0
    end

    return self
  end
end
