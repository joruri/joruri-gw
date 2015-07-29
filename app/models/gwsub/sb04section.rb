# -*- encoding: utf-8 -*-
class Gwsub::Sb04section < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to  :fy_rel     ,:foreign_key=>:fyear_id      ,:class_name=>'Gw::YearFiscalJp'
  has_many    :staffs     ,:foreign_key=>:section_id    ,:class_name=>'Gwsub::Sb04stafflist' , :order=>'kana'

  validates_presence_of :code
  validates_presence_of :name
  validates_presence_of :ldap_code

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
    if self.ldap_code.size ==5
      self.ldap_code = self.ldap_code.to_s+'0'
    end
    g_cond  = "state='enabled' and code='#{self.ldap_code}' and end_at is null"
    g_order = "start_at DESC"
    group = System::GroupHistory.find(:first,:conditions=>g_cond,:order=>g_order)
    if group.blank?
      self.ldap_name  = nil
    else
      self.ldap_name  = group.name
    end
  end
  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def section_data_save(params, mode, options={})
    par_item = params[:item].dup

    if par_item[:code].blank?
      self.errors.add :code, "を入力してください。"
    end

    if par_item[:fyear_id].blank?
      self.errors.add :fyear_id, "を入力してください。"
    else
      if mode == :update
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ? and id != ?",par_item[:code],par_item[:fyear_id],self.id])
        self.errors.add :code, "は、既に登録されています。" unless item.blank?
      elsif mode == :create
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ?",par_item[:code],par_item[:fyear_id]])
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

  def self.sb04_group_select(fyear_id = nil,all = nil,options={})
    role_developer  = Gwsub::Sb04stafflist.is_dev?(Site.user.id)
    role_admin      = Gwsub::Sb04stafflist.is_admin?(Site.user.id)
    u_role = role_developer || role_admin

    selects = []
    if options[:form].to_i == 1
      return selects << ['年度未選択','0'] if fyear_id.to_i==0
    end

    g_order = "fyear_markjp DESC , code ASC"
    if fyear_id.to_i==0
      items = Gwsub::Sb04section.find(:all,:order=>g_order)
    else
      g_cond  = "fyear_id=#{fyear_id}"
      items = Gwsub::Sb04section.find(:all,:order=>g_order,:conditions=>g_cond)
    end

    return selects << ['所属未設定','0'] if items.blank?

    if u_role==true
    else
      fyear_conditions = "published_at <= '#{Gw.date_common(Time.now)}'"
      fyear_order = "published_at DESC"
      fyears = Gwsub::Sb04EditableDate.find(:all , :conditions=>fyear_conditions , :order=>fyear_order)
      markjp = fyears[0].fyear_markjp
    end

    selects << ['すべて' , '0'] if all.to_s.blank?
    items.each do |g|
      if u_role==true
          selects << [g.name ,g.id]
      else
        if g.fyear_markjp <= markjp
          selects << [g.name ,g.id]
        end
      end
    end
    return selects
  end

  def self.sb04_edit_ldap_group_select(fyear_id = nil, all = '', options={})
    # 電子事務分掌の編集期間で、一般ユーザーは自分の所属のみ表示させる
    selects = []
    return selects << ['所属未設定','0'] if fyear_id.blank?
    sections = Gwsub::Sb04section.find(:all, :conditions=>"fyear_id = #{fyear_id} and ldap_code = '#{Site.user_group.code}'")
    return selects << ['所属未設定','0'] if sections.empty?

    sections.each do |section|
      selects << [section.name ,section.id]
    end
    selects = [['すべて', 0]] + selects if all.to_s.blank?
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
      when 'grped_id'
        search_id v,:id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gwsub_sb04sections` ;"
    connect.execute(truncate_query)
  end
end
