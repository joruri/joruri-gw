# -*- encoding: utf-8 -*-
class Gwsub::Sb04assignedjob < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  belongs_to :fy_rel     ,:foreign_key=>:fyear_id           ,:class_name=>'Gw::YearFiscalJp'
  belongs_to :section    ,:foreign_key=>:section_id         ,:class_name=>'Gwsub::Sb04section'
  has_many   :staffs     ,:foreign_key=>:assignedjobs_id    ,:class_name=>'Gwsub::Sb04stafflist'

  validates_presence_of :section_id
  validates_presence_of :code

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save   :before_save_setting_columns

  def assignedjob_data_save(params, mode, options={})
    par_item = params[:item].dup

    if !par_item[:code].blank? && par_item[:code] !~ /^[0-9A-Za-z\_]+$/
      self.errors.add :code, "は、半角英数字およびアンダーバー（_）で入力してください。"
    end

    if par_item[:fyear_id].blank?
      self.errors.add :fyear_id, "を入力してください。"
    else
      if mode == :update
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ? and id != ? and section_id = ?",par_item[:code],par_item[:fyear_id],self.id,par_item[:section_id]])
        self.errors.add :code, "は、既に登録されています。" unless item.blank?
      elsif mode == :create
        item = self.find(:first,
          :conditions=>["code = ? and fyear_id = ? and section_id = ?",par_item[:code],par_item[:fyear_id],par_item[:section_id] ])
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
    if self.section_id.to_i == 0
      if self.section_code.blank?
      else
        order = "code"
        conditions = "fyear_markjp = '#{self.fyear_markjp}' and code = '#{self.section_code}'"
        section = Gwsub::Sb04section.find(:first,:conditions=>conditions,:order=>order)
        if section.blank?
          self.section_id = 0
        else
          self.section_id = section.id
        end
      end
    else
      self.section_code = self.section.code
      self.section_name = self.section.name
    end
    self.code_int     = self.code.to_i
  end
  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def self.sb04_assignedjobs_select(fyear_id = nil, section_id = 0 )
    selects=[]
    return selects << ['年度未選択','0'] if fyear_id.to_i==0
    return selects << ['所属未選択','0'] if section_id.to_i==0

    item = Gwsub::Sb04assignedjob.new
    item.fyear_id     = fyear_id
    item.section_id   = section_id
    item.order "fyear_markjp DESC , section_code ASC , code ASC"
    items = item.find(:all)
    return selects << ['担当未設定' ,'0'] if items.blank?

    items.each do |g|
      selects << [g.name.to_s + '(' + g.code + ')' ,g.code]
    end
    return selects
  end

  def self.sb04_assignedjobs_id_select(fyear_id = nil, section_id = 0 )
#pp fyear_id,section_id
    selects = []
    return selects << ['年度未選択' ,'0'] if fyear_id.to_i==0
    return selects << ['所属未選択' ,'0'] if section_id.to_i==0

    assigned_job = Gwsub::Sb04assignedjob.new
    assigned_job.fyear_id   = fyear_id    unless fyear_id.to_i == 0
    assigned_job.section_id = section_id  unless section_id.to_i == 0
    assigned_job.order "fyear_markjp DESC , section_code ASC , code ASC"
    items = assigned_job.find(:all)
    selects << ['担当未設定' ,'0']  if items.blank?

    items.each do |g|
      selects << [g.name.to_s + '(' + g.code + ')' ,g.id]
    end
    return selects
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:code,:name,:remarks,:section_name,:tel
      when 'fyed_id'
        search_id v,:fyear_id if v.to_i != 0
      when 'grped_id'
        search_id v,:section_id if v.to_i != 0
      end
    end if params.size != 0

    return self
  end


  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `gwsub_sb04assignedjobs` ;"
    connect.execute(truncate_query)
  end

  def self.year_copy_assignedjobs(par_item, auth = Hash::new)
    # 年度の違うデータをコピーする。
    ret = Hash::new
    msg = Array.new

    origin_fyear         = Gw::YearFiscalJp.find_by_id(par_item[:origin_fyear_id])
    destination_fyear    = Gw::YearFiscalJp.find_by_id(par_item[:destination_fyear_id])
    destination_section  = Gwsub::Sb04section.find_by_id(par_item[:destination_section_id])

    if origin_fyear.start_at >= destination_fyear.start_at
      ret[:result]    = false
      msg << ['エラー' ,"コピー元の年度が、コピー先の年度以降となっています。コピー元は、コピー先より前の年度を指定してください。"]
    end

    division_sb04_gids = Gwsub::Sb04stafflistviewMaster.get_division_sb04_gids
    if (division_sb04_gids.empty? || division_sb04_gids.index(par_item[:destination_section_id].to_i).blank?) && auth[:u_role] != true

      ret[:result]    = false
      msg << ['エラー' ,"コピー先の所属が、自所属もしくは主管課ではありません。コピー先は、自所属もしくは主管課を指定してください。"]
    end

    items = self.find(:all, :conditions => ["fyear_id = ? and section_id = ?", par_item[:origin_fyear_id].to_i, par_item[:origin_section_id].to_i ],
      :order => 'id')
    if items.blank?
      ret[:result]    = false
      msg << ['エラー' ,"コピー元の所属に担当が登録されていません。コピー元を選びなおしてください。"]
    end

    if ret[:result] == false
      ret[:msg] = msg
      return ret
    else

      # コピー先所属を削除
      self.destroy_all(["fyear_id = ? and section_id = ?", par_item[:destination_fyear_id].to_i, par_item[:destination_section_id].to_i ])
      # コピー
      fields = Array.new
      items = self.find(:all, :conditions => ["fyear_id = ? and section_id = ?", par_item[:origin_fyear_id].to_i, par_item[:origin_section_id].to_i ],
        :order => 'id')

      self.columns.each do |column|
        fields << "#{column.name}"
      end

      save_cnt = items.length
      items.each_with_index do |item, i|
        model = self.new
        model.class.before_save.clear # コールバックをフックして無効化する。
        fields.each do |field|
          case field.to_s
          when 'id', 'updated_user', 'updated_group', 'created_user', 'created_group' # id等はコピーしない
          when 'fyear_id'
            model.fyear_id     = destination_fyear.id
          when 'fyear_markjp'
            model.fyear_markjp = destination_fyear.markjp
          when 'section_id'
            model.section_id   = destination_section.id
          when 'section_code'
            model.section_code = destination_section.code
          when 'section_name'
            model.section_name = destination_section.name
          when 'created_at'
            model.created_at   = Time.now
          when 'updated_at'
            model.updated_at   = Time.now
          else
            eval("model.#{field} = nz(item.#{field}, nil)")
          end
        end
        model.save(:validate=>false)
      end

      Gwsub::Sb04YearCopyLog.create_log('assignedjob',
        par_item[:origin_fyear_id], par_item[:origin_section_id], par_item[:destination_fyear_id], par_item[:destination_section_id])

      ret[:result]    = true
      msg << "#{save_cnt}件のデータをコピーしました。"
      ret[:msg] = msg
      return ret
    end
  end
end
