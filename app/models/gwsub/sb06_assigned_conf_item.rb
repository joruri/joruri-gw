class Gwsub::Sb06AssignedConfItem < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :c_kind1    ,:foreign_key=>:conf_kind_id   ,:class_name => 'Gwsub::Sb06AssignedConfKind'

  validates_presence_of :conf_kind_id
  validates_presence_of :item_title
  validates_presence_of :item_max_count
#  validates_uniqueness_of :item_title ,:scop=>:conf_kind_id ,:message=>'は登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb06_assign_conf_item_id_select(options={})
    # options
    # :c_kind_id  申請書種別
    # :all        「すべて」要否
    order = "item_sort_no ASC"
    item = Gwsub::Sb06AssignedConfItem.new
    item.select_list  =1
    item.conf_kind_id = options[:c_kind_id]    unless (!options[:c_kind_id]   or options[:c_kind_id].to_i==0)
    items = item.find(:all,:order=>order)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    items.each do |g|
      selects << [g.item_title ,g.id]
    end
    return selects
  end
  def self.sb06_assign_conf_item_get(options={})
    order = "item_sort_no ASC"
    item = Gwsub::Sb06AssignedConfItem.new
    item.select_list  =1
    items = item.find(:all,:order=>order)
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
        search_keyword v,:item_sort_no,:item_title
      when 'c_kind_id'
        search_id v,:conf_kind_id unless v.to_i==0
      when 'fy_id'
        search_id v,:fyear_id unless v.to_i==0
      end
    end if params.size != 0

    return self
  end
end
