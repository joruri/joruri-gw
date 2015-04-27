class Gwsub::Sb06AssignedConfGroup < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :fy          ,:foreign_key=>:fyear_id        ,:class_name => 'Gw::YearFiscalJp'
  belongs_to :grp1        ,:foreign_key=>:group_id        ,:class_name => 'System::GroupHistory'
  belongs_to :cat         ,:foreign_key=>:categories_id   ,:class_name => 'Gwsub::Sb06AssignedConfCategory'

#  validates_presence_of :fyear_id
  validates_presence_of :fyear_id,:group_id
  validates_uniqueness_of :group_id ,:scope=>[:fyear_id] ,:message=>'は登録済です。' ,:unless=>Proc.new{ |item| item.group_id.to_i==0}

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
    unless self.fyear_id.to_i==0
      self.fyear_markjp  = self.fy.markjp
    end
    unless self.group_id.to_i==0
      self.group_code    = self.grp1.code
      self.group_name    = self.grp1.name
    end
    unless self.categories_id.to_i==0
      self.cat_sort_no  = self.cat.cat_sort_no
      self.cat_code     = self.cat.cat_code
      self.cat_name     = self.cat.cat_name
    end
  end

  def self.sb06_assign_conf_group_id_select(options={})
    # options
    # :cat_id 申請書分類id 管理対象申請書分類を絞り込む
    # :fy_id  年度id 対象年度を絞り込む
    # :g_id   所属id 対象所属を絞り込む
    # :code   1:選択肢にコードを付加
    # :all    選択肢の先頭に「すべて」を表示
#    order = "fyear_id DESC , group_code ASC"
#    order = "fyear_id DESC , group_sort_no ASC"
    order = "fyear_markjp DESC , cat_sort_no ASC"
    item = Gwsub::Sb06AssignedConfGroup.new
    item.fyear_id       = options[:fy_id]    unless ( !options[:fy_id]  or options[:fy_id].to_i==0 )
    item.group_id       = options[:g_id]     unless ( !options[:g_id]   or options[:g_id].to_i==0  )
    item.categories_id  = options[:cat_id]   unless ( !options[:cat_id]   or options[:cat_id].to_i==0  )
    items = item.find(:all,:order=>order)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    items.each do |g|
      selects << [g.group_name ,g.id] if ( !options[:code] or options[:code].to_i!=1)
      selects << ['('+g.group_code+')'+g.group_name ,g.id] if options[:code].to_i==1
    end
    return selects
  end
  def self.sb06_assign_conf_group_get(options={})
    order = "fyear_id DESC , group_code ASC"
    item = Gwsub::Sb06AssignedConfGroup.new
    if options[:fyear_id]
      item.fyear_id = options[:fyear_id].to_i
    end
    items = item.find(:all,:order=>order)
    return items
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:group_code,:group_name
      when 'cat_id'
        search_id v,:categories_id unless v.to_i==0
      when 'fy_id'
        search_id v,:fyear_id unless v.to_i==0
      #when 'c_group_id'
      #  search_id v,:id unless v.to_i==0
      when 'group_id'
        search_id v,:group_id unless v.to_i==0
      end
    end if params.size != 0

    return self
  end
end
