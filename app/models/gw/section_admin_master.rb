class Gw::SectionAdminMaster < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :r_user, :foreign_key => :management_uid, :class_name => 'System::User'
  belongs_to :r_dept1, :foreign_key => :management_parent_gid, :class_name => 'System::Group'
  belongs_to :r_sect1, :foreign_key => :management_gid, :class_name => 'System::Group'
  belongs_to :r_dept2, :foreign_key => :division_parent_gid, :class_name => 'System::Group'
  belongs_to :r_sect2, :foreign_key => :division_gid, :class_name => 'System::Group'
  belongs_to :sb_04_fy_rel, :foreign_key => :fyear_id_sb04, :class_name => 'Gw::YearFiscalJp'

  before_validation :set_parent
  before_create :set_creator
  before_update :set_updator

  validates :func_name, presence: true
  validate :validates_gw_event, :if => lambda {|item| item.func_name == 'gw_event'}
  validate :validates_gw_props, :if => lambda {|item| item.func_name == 'gw_props'}
  validate :validates_gwsub_sb04, :if => lambda {|item| item.func_name == 'gwsub_sb04'}
  validate :validates_gwsub_sb09, :if => lambda {|item| item.func_name == 'gwsub_sb09'}

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_m_gid'
        search_id2 v.to_i, :management_parent_gid,:management_gid  unless v.to_i == 0
      when 's_d_gid'
        search_id2 v.to_i, :division_parent_gid,:division_gid  unless v.to_i == 0
      end
    end if params.size != 0

    return self
  end

  def self.state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    status = state_select + ['削除','deleted']
    status.blank? ? '有効' : status.rassoc(state).try(:first)
  end

  def self.range_select
    [['部局',1],['所属',2]]
  end

  def self.range_show(range)
    range.to_i == 0 ? '部局' : range_select.rassoc(range).try(:first)
  end

  def common_presence
    ret = true
    #:management_parent_gid, :management_gid, :management_uid, :range_class_id, :division_parent_gid
    if self.management_parent_gid.blank?
        errors.add :management_parent_gid, 'を入力してください。'
        ret = false
    end
    if self.management_gid.blank?
        errors.add :management_gid, 'を入力してください。'
        ret = false
    end
    if self.management_uid.blank?
        errors.add :management_uid, 'を入力してください。'
        ret = false
    end
    if self.range_class_id.blank?
        errors.add :range_class_id, 'を入力してください。'
        ret = false
    end
    if self.division_parent_gid.blank?
        errors.add :division_parent_gid, 'を入力してください。'
        ret = false
    end
    if self.range_class_id == 2
      if self.division_gid.blank?
          errors.add :division_gid, 'を入力してください。'
          ret = false
      end
    end
    return ret
  end

  def self.find_uniqueness(_params, action = nil, id = nil, model = Gw::SectionAdminMaster)
    # 重複チェック
    cond = "management_parent_gid = #{_params[:management_parent_gid]}"
    cond.concat " and func_name = #{_params[:func_name]}"
    cond.concat " and management_gid = #{_params[:management_gid]}"
    cond.concat " and management_uid = #{_params[:management_uid]}"
    cond.concat " and range_class_id = #{_params[:range_class_id]}"
    cond.concat " and division_parent_gid = #{_params[:division_parent_gid]}"
    cond.concat " and division_gid = #{_params[:division_gid]}" unless _params[:division_gid].blank?
    cond.concat " and id <> #{id}" if action == :update

    _item = model.where(cond).first

    if _item.blank?
      return true
    else
      return false
    end
  end

  def self.params_set(params)
    ret = ""
    'page:sort_keys:s_m_gid:s_d_gid:s_func_name'.split(':').each_with_index do |col, idx|
      unless params[col.to_sym].blank?
        ret.concat "&" unless ret.blank?
        ret.concat "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def self.select_clear(func_name = '')
    # 主管課マスタの一括削除
    dump "主管課マスタの一括削除が開始されました。開始時刻：#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    unless func_name.blank?
      dump_func_name = Gw::SectionAdminMasterFuncName.get_func_name(func_name)
      dump "削除対象は「#{dump_func_name}」です。"

      if func_name == 'all'
        where =  "state != 'deleted'"
      else
        where =  "func_name = '#{func_name}' and state != 'deleted'"
      end

      self.record_timestamps = false # updated_atの更新を停止
      self.where(where).update_all(:state => 'deleted', :deleted_at => Time.now, :deleted_uid => Core.user.id, :deleted_gid => Core.user_group.id)
      self.record_timestamps = true  # updated_atの更新を再開
      dump "主管課マスタの一括削除が終了しました。終了時刻：#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
      return true
    else
      dump "削除対象に異常があったため、失敗しました。削除対象は「#{func_name}」を指定しています。終了時刻：#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
      return false
    end
  end

private

  def validates_gw_event
    # 行事予定表チェック
    return true unless self.func_name=='gw_event'
    ret = true
    ret = common_presence
    return ret
  end

  def validates_gw_props
    # レンタカー所属別実績公開先チェック
    return true unless self.func_name=='gw_props'
    ret = true
    ret = common_presence
    return ret
  end

  def validates_gwsub_sb09
    # 端末管理用チェック
    return true unless self.func_name=='gwsub_sb09'
    ret = true
    ret = common_presence
    return ret
  end

  def validates_gwsub_sb04
    # 電子職員録用チェック
    return true unless self.func_name=='gwsub_sb04'
    return true
  end

  def set_parent
    if self.management_gid.to_i==0
      self.management_parent_gid = 0
      return
    end
    group = self.r_sect1
    if group.blank?
      self.management_parent_gid = 0
      return
    end
    self.management_parent_gid = group.parent_id
    return
  end

  def set_creator
    self.creator_uid = Core.user.id
    self.creator_gid = Core.user_group.id
  end

  def set_updator
    self.updator_uid = Core.user.id
    self.updator_gid = Core.user_group.id
  end
end
