# -*- encoding: utf-8 -*-
class Gwsub::Sb01Training < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fyear    ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'
  belongs_to :group    ,:foreign_key=>:group_id      ,:class_name=>'System::Group'
  belongs_to :member   ,:foreign_key=>:member_id     ,:class_name=>'System::User'

  validates_presence_of :categories
  validates_presence_of :fyear_id
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :group_id
  validates_presence_of :member_id
  validates_presence_of :member_tel
  #validates_presence_of :members_max
  #validates_numericality_of :members_max
  #validates_presence_of :bbs_url

#  validates_uniqueness_of :categories , :scope => [:fyear_id,:bbs_url] ,:message=>'は、年度内で登録済です。'
  #validates_uniqueness_of :title      , :scope => [:fyear_id] ,:message=>'が、年度内で重複しています。'
  validates_length_of :title,  :maximum => 70

  before_save :before_save_setting_columns
#  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'gwsub', 'developer')
  end
  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'sb01', 'admin')
  end
  def self.is_editor?(org_code , g_code = Site.user_group.group_code)
    return false unless g_code.to_s == org_code.to_s
    return true
  end

  def states_no
    [['準備中',1], ['受付中',2], ['締切 ',3], ['終了',4], ['その他 ',5]]
  end

  def state_label
    states_no.each {|a| return a[0] if a[1] == state.to_i }
    return nil
  end

  def self.state_list
    Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
  end
  def self.state_show(state)
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
    states = []
    list2.each do |value , key|
      states << [key,value]
    end
    show = states.assoc(state)
    return show[1] unless show.blank?
    return ''
  end
  def self.state_select(all=nil)
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_states'
    lists = []
    if all=='all'
      lists.push ['すべて','0']
    end
    lists = lists + list2
    return lists
  end

  def self.select_cats(all=nil)
    lists = []
    if all=='all'
      lists.push ['すべて','0']
    end
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_categories'
    lists = lists + list2
    return lists
  end
  def self.show_cats(categories)
    if categories.to_s == '0'
      return 'すべて'
    end
    list2 = Gw.yaml_to_array_for_select 'gwsub_sb01_training_categories'
    cats = []
    list2.each do |value , key|
      cats << [key,value]
    end
    show = cats.assoc(categories.to_s)
    return show[1]
  end

  def self.select_titles(options={})
    title = Gwsub::Sb01Training.new
    title.categories = '1'
    title.order "fyear_markjp DESC , updated_at DESC"
    titles = title.find(:all)
    selects = []
    selects << ['すべて',0] if options[:all]=='all'
    titles.each do |t|
      selects << [t.title,t.id]
    end
    return selects
  end

  def self.set_f(params_item)
    new_item = params_item
    fyear = Gw::YearFiscalJp.find(params_item['fyear_id'])
    new_item['fyear_markjp'] = fyear.markjp
    return new_item
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end
  def before_save_setting_columns
    unless self.member_id == 0
      self.member_code = self.member.code
      self.member_name = self.member.name
    end
    unless self.group_id == 0
      self.group_code = self.group.code
      self.group_name = self.group.name
    end
  end


  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:fyear_markjp,:title,:bbs_url,:body
      when 'cat'
        search_equal v,:categories unless (v.to_s == '0' || v.to_s == nil)
      when 'g_id'
        search_id v,:group_id unless (v.to_s == '0' || v.to_s == nil)
      end
    end if params.size != 0

    return self
  end
end
