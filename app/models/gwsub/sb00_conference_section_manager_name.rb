class Gwsub::Sb00ConferenceSectionManagerName < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :fyear_r   ,:foreign_key=>:fyear_id    ,:class_name => 'Gw::YearFiscalJp'
  belongs_to :grp1      ,:foreign_key=>:gid         ,:class_name => 'System::Group'
  belongs_to :p_grp1    ,:foreign_key=>:parent_gid  ,:class_name => 'System::Group'

  validate :check_items
  before_save :set_items

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin', 'sb00/admin')
  end

  def self.state
    status = [['有効','enabled'],['無効','disabled']]
    return status
  end
  def self.state_show(state)
    status = [['有効','enabled'],['無効','disabled'],['削除','deleted']]
    show_str = nil
    status.each do |s|
      if s[1].to_s==state.to_s
        show_str = s[0]
        break
      end
    end
    return show_str
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:g_code,:g_name,:manager_name
      when 'fyear_id'
        search_id v,:fyear_id unless v.to_i==0
      when 'p_gid'
        search_id v,:parent_gid unless v.to_i==0
      when 'gid'
        search_id v,:gid unless v.to_i==0
      end
    end if params.size != 0

    return self
  end

  def check_items
    valid = true
    # 所属選択
    if self.gid.to_i==0
      errors.add :gid, 'を選択してください。'
      valid = false
    #else
      # 20110608 重複チェックは行わない
      # 重複チェック
    #  g_cond  = "gid=#{self.gid} and state != 'deleted'"
    #  g_order = "g_sort_no"
    #  names = Gwsub::Sb00ConferenceSectionManagerName.find(:all , :conditions=>g_cond ,:order=>g_order)
    #  unless names.blank?
    #    # 削除以外がすでにある場合
    #    if names.size == 1
    #      if names[0].id==self.id
    #        #自分の編集は許可
    #      else
    #        # 自分以外がある場合
    #        errors.add :gid, 'は登録済です。'
    #        valid = false
    #      end
    #    else
    #      # 自分以外がある場合
    #      errors.add :gid, 'は登録済です。'
    #      valid = false
    #    end
    #  end
    end
    # 所属長名
    if self.manager_name.blank?
      errors.add :manager_name, 'を入力してください。'
      valid = false
    end
    return valid
  end

  def set_items
    # gidから設定値を取得
    unless self.gid.to_i==0
      group = System::Group.find_by_id(self.gid)
      unless group.blank?
        self.parent_gid = group.parent_id
        self.g_sort_no  = group.sort_no
        self.g_code     = group.code
        self.g_name     = group.name
      end
    end
  end

  def self.get_g_names(group_id)
    fyear = Gw::YearFiscalJp.get_record(Time.now.strftime("%Y-%m-%d"))
    if fyear.blank?
      c_groups = Gwsub::Sb00ConferenceSectionManagerName.where("gid = ? AND state = ?", group_id,"enabled").order(:g_sort_no)
    else
      c_groups = Gwsub::Sb00ConferenceSectionManagerName.where("gid = ? AND state = ? AND fyear_id = ? ", group_id,"enabled",fyear.id).order(:g_sort_no)
    end
    group_list = []
    if c_groups.blank?
      #group_list = Gwsub.section_manager_names(nil, nil , u_role, nil)
    else
      c_groups.each do |g|
        group_list << ["(#{g.g_code})#{g.manager_name}" ,g.id ]
      end
    end
    return group_list
  end

end
