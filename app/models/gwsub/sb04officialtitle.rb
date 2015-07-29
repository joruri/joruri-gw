# -*- encoding: utf-8 -*-
class Gwsub::Sb04officialtitle < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fy_rel     ,:foreign_key=>:fyear_id           ,:class_name=>'Gw::YearFiscalJp'
  has_many :staffs       ,:foreign_key=>:official_title_id  ,:class_name=>'Gwsub::Sb04stafflist'

  validates_presence_of :code
  validates_presence_of :name

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save   :before_save_setting_columns

  def before_save_setting_columns
    if self.fyear_id.to_i==0
      if self.fyear_markjp.blank?
      else
        order = "start_at DESC"
        conditions = "markjp = '#{self.fyear_markjp}'"
        fyear = Gw::YearFiscalJp.find(:first,:conditions=>conditions,:order=>order)
        self.fyear_id = fyear.id
      end
    else
      self.fyear_markjp = self.fy_rel.markjp
    end
    self.code_int = Gwsub.convert_char_ascii(self.code).to_i
  end
  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def officialtitle_data_save(params, mode, options={})
    par_item = params[:item].dup

    if !par_item[:code].blank? && par_item[:code] !~ /^[0-9A-Za-z\_]+$/
      self.errors.add :code, "は、半角英数字およびアンダーバー（_）で入力してください。"
    end

    if par_item[:fyear_id].blank?
      self.errors.add :fyear_id, "を入力してください。"
    else
      if mode == :update
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ? and id != ?",par_item[:code],par_item[:fyear_id],self.id ])
        self.errors.add :code, "は、既に登録されています。" unless item.blank?
      elsif mode == :create
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ?", par_item[:code],par_item[:fyear_id]])
        self.errors.add :code, "は、既に登録されています。" unless item.blank?
      end
    end

    self.attributes = par_item
    if mode == :update
      save_flg = self.errors.size == 0 && self.editable? && self.save()
    elsif mode == :create
      save_flg = self.errors.size == 0 && self.creatable? && self.save()
    end

    return save_flg
  end

  def self.sb04_official_titles_select(fyear_id = nil)
    selects = []
    return selects << ['年度未選択','0'] if fyear_id.to_i==0

    order = "fyear_markjp DESC , code_int ASC"
    select = "id,fyear_id,code,name"
    item = Gwsub::Sb04officialtitle.new
    item.fyear_id = fyear_id
    items = item.find(:all,:select=>select,:order=>order)
    return selects << ['職名未設定','0'] if items.blank?

    items.each do |g|
      selects << [g.name ,g.code]
    end
    return selects
  end

  def self.sb04_official_titles_id_select(fyear_id = nil)
    selects = []
    return selects << ['年度未選択','0'] if fyear_id.to_i==0

    order = "fyear_markjp DESC , code_int ASC"
    select = "id,fyear_id,code,name"
    item = Gwsub::Sb04officialtitle.new
    item.fyear_id = fyear_id
    items = item.find(:all,:select=>select,:order=>order)
    return selects << ['職名未設定','0'] if items.blank?

    items.each do |g|
      selects << [g.name ,g.id]
    end
    return selects
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:code,:name,:remarks
      when 'fyed_id'
        search_id v,:fyear_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gwsub_sb04officialtitles` ;"
    connect.execute(truncate_query)
  end
end
