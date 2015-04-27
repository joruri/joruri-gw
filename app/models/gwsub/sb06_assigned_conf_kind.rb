class Gwsub::Sb06AssignedConfKind < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to  :fyear_r     ,:foreign_key=>:fyear_id        ,:class_name => 'Gw::YearFiscalJp'
  belongs_to  :cat         ,:foreign_key=>:conf_cat_id     ,:class_name => 'Gwsub::Sb06AssignedConfCategory'

  validates_presence_of :fyear_id
  validates_presence_of :conf_cat_id
  validates_presence_of :conf_kind_code,:conf_kind_name,:conf_menu_name
  validates_presence_of :conf_title,:conf_form_no,:conf_max_count, :conf_body
#  validates_uniqueness_of :conf_group_id ,:message=>'は登録済です。'
  validates_uniqueness_of :conf_kind_code ,:scope=>:fyear_id ,:message=>'は登録済です。'
  validates_uniqueness_of :conf_kind_name ,:scope=>:fyear_id ,:message=>'は登録済です。'
#  validates_uniqueness_of :conf_title ,:message=>'は登録済です。'
#  validates_uniqueness_of :conf_form_no ,:message=>'は登録済です。'

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save :before_save_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def before_save_setting_columns
    # id=>code/name
#    unless self.conf_cat_id.to_i==0
#      self.group_code    = self.grp1.code
#      self.group_name    = self.grp1.name
#    end
    unless self.fyear_id.to_i==0
      self.fyear_markjp = self.fyear_r.markjp unless self.fyear_id.blank?
    end
  end

  def self.sb06_assign_conf_kind_id_select(options={})
    # options
    # :feyar_id 年度絞り込み　指定がないときは、実行日の年度
    # :cat_id   申請書の分類を絞り込む
    # :code     1:選択肢にコードを付与
    # :all      選択肢の先頭に「すべて」を表示
    #
    all     = nil
    code    = nil
    cat_id  = nil
    fyear_id  = nil
    all     = options[:all]     if ( !options.blank? and options.has_key?(:all) )
    code    = options[:code]    if ( !options.blank? and options.has_key?(:code) )
    cat_id  = options[:cat_id]  if ( !options.blank? and options.has_key?(:cat_id) )
    if ( !options.blank? and options.has_key?(:fyear_id) )
      fyear_id  = options[:fyear_id]
    else
      fyear = Gw::YearFiscalJp.get_record(Time.now)
      fyear_id  = fyear.id
    end
#pp ['model',options,all,code,cat_id]
    item = Gwsub::Sb06AssignedConfKind.new
    item.fyear_id = fyear_id
    item.conf_cat_id  = cat_id.to_i unless cat_id.to_i===0
    item.select_list  = 1
    item.order "conf_kind_sort_no ASC , conf_kind_code ASC"
    items = item.find(:all)
    selects = []
    selects << ['すべて',0] if all=='all'
    items.each do |g|
      selects << [g.conf_kind_name ,g.id]                           unless  code.to_i==1
      selects << ['('+g.conf_kind_code+')'+g.conf_kind_name ,g.id]  if      code.to_i==1
    end
    return selects
  end

  def self.sb06_assign_conf_kind_get(options={})
#    order = "conf_kind_sort_no ASC , conf_kind_code ASC"
    item = Gwsub::Sb06AssignedConfKind.new
#    items = item.find(:all,:order=>order)
    item.select_lsit  =1
    item.fyear_id = options[:fyear_id] if ( !options.blank? and options.has_key?(:fyear_id) )
    item.order "fyear_markjp desc , conf_kind_sort_no ASC , conf_kind_code ASC"
    items = item.find(:all)
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
        search_keyword v,:conf_kind_name,:conf_to_name,:conf_menu_name,:conf_title
      when 'cat_id'
        search_id v,:conf_cat_id unless v.to_i==0
      when 'fyear_id'
        search_id v,:fyear_id unless v.to_i==0
      end
    end if params.size != 0

    return self
  end
end
