class Gw::SectionAdminMasterFuncName < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

  validates_presence_of :name, :func_name
  validates_uniqueness_of :func_name, :scope => [:deleted_at]
  validates_numericality_of :sort_no

  default_scope -> { where.not(:state => 'deleted') }

  def self.params_set(params)
    ret = ""
    'page'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.func_name_all_select
    ret_array = [['すべて', 'all']]
    ret_array += self.where(:state => 'enabled').order(:sort_no, :id).all.map{|item| [item.name, item.func_name]}
    return ret_array
  end

  def self.func_name_rule_select(func_names = Array.new)
    ret_array = Array.new
    return ret_array if func_names.empty?

    items = self.find(:all, :conditions => ["func_name in (?) and state = 'enabled'", func_names], :order => 'sort_no, id')

    if !items.blank? && !items.empty?
      items.each do |item|
        ret_array << [item.name, item.func_name]
      end
      return ret_array
    else
      return ret_array
    end

  end
  
  def self.get_func_name(func_name = '')
    return '' if func_name.blank?
    return 'すべて' if func_name == 'all'

    self.where(:func_name => func_name, :state => 'enabled').select(:name).first.try(:name)
  end

private

  def set_creator
    self.creator_uid = Core.user.id
    self.creator_gid = Core.user_group.id
  end

  def set_updator
    self.updator_uid = Core.user.id
    self.updator_gid = Core.user_group.id
  end
end
