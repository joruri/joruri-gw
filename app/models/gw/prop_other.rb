class Gw::PropOther < Gw::PropBase
  include System::Model::Base
  include System::Model::Base::Content

  has_many :images, ->{ order(:id) }, :foreign_key => :parent_id, :class_name => 'Gw::PropOtherImage', :dependent => :destroy
  has_many :schedule_props, :class_name => 'Gw::ScheduleProp', :as => :prop
  has_many :schedules, :through => :schedule_props
  has_many :prop_other_roles, ->{ order(:id) }, :foreign_key => :prop_id, :class_name => 'Gw::PropOtherRole'
  belongs_to :prop_type, :foreign_key => :type_id, :class_name => 'Gw::PropType'
  belongs_to :owner_group, :foreign_key => :gid, :class_name => 'System::Group'

  accepts_nested_attributes_for :images

  validates :name, :type_id, presence: true

  scope :with_reservable, -> { where(reserved_state: 1) }
  scope :with_user_auth, ->(user = Cpre.user, auth) {
    gids = [0] + user.groups.first.self_and_ancestors.map(&:id)
    joins(:prop_other_roles).merge(Gw::PropOtherRole.with_auth_and_gids(auth, gids))
  }

  def get_type_class
    case self.type_id
    when 200 then "room"
    when 100 then "car"
    else "other"
    end
  end

  def display_prop_name
    gname = self.gname.presence ||
      admin_prop_other_roles.first.try(:group).try(:name) ||
      admin_prop_other_roles.first.try(:group_history).try(:name)
    "#{name}(#{gname})"
  end

  def display_prop_name_for_select
    "(#{owner_group.try(:code)})#{name}"
  end

  def is_admin?(user = Core.user)
    Gw.is_admin_admin?(user) || prop_other_roles.any? {|r| r.auth_admin? && r.gid == user.groups.first.try(:id) }
  end

  def is_edit?(user = Core.user)
    gids = user.groups.first.self_and_ancestors.map(&:id)
    Gw.is_admin_admin?(user) || prop_other_roles.any? {|r| r.auth_edit? && gids.include?(r.gid) }
  end

  def is_read?(user = Core.user)
    gids = [0] + user.groups.first.self_and_ancestors.map(&:id)
    Gw.is_admin_admin?(user) || prop_other_roles.any? {|r| r.auth_read? && gids.include?(r.gid) }
  end

  def is_admin_or_editor_or_reader?(user = Core.user)
    is_admin?(user) || is_edit?(user) || is_read?(user)
  end

  def reserved_state_options
    [['不可',0],['許可',1]]
  end

  def reserved_state_label
    reserved_state_options.rassoc(reserved_state).try(:first)
  end

  def admin_prop_other_roles
    prop_other_roles.select(&:auth_admin?)
  end

  def edit_prop_other_roles
    prop_other_roles.select(&:auth_edit?)
  end

  def read_prop_other_roles
    prop_other_roles.select(&:auth_read?)
  end

  def admin_role_gids
    admin_prop_other_roles.map(&:gid)
  end

  def edit_role_gids
    edit_prop_other_roles.map(&:gid)
  end

  def read_role_gids
    read_prop_other_roles.map(&:gid)
  end

  def admin_role_corrected_group_options
    corrected_group_options(admin_prop_other_roles)
  end

  def edit_role_corrected_group_options
    corrected_group_options(edit_prop_other_roles)
  end

  def read_role_corrected_group_options
    corrected_group_options(read_prop_other_roles)
  end

  def admin_role_corrected_group_names
    corrected_group_names(admin_prop_other_roles)
  end

  def edit_role_corrected_group_names
    corrected_group_names(edit_prop_other_roles)
  end

  def read_role_corrected_group_names
    corrected_group_names(read_prop_other_roles)
  end

  def save_with_rels(params, mode, options={})

    admin_groups = ::JSON.parse(params[:item][:admin_json])
    edit_groups = ::JSON.parse(params[:item][:editors_json])
    read_groups = ::JSON.parse(params[:item][:readers_json])

    gid = nz(params[:item]['sub']['gid'])
    uid = nz(params[:item]['sub']['uid'])
    ad_gnames = []
    now = Time.now

    if params[:item][:sort_no].blank?
      params[:item][:sort_no] = 0
    elsif /^[0-9]+$/ =~ params[:item][:sort_no] && params[:item][:sort_no].to_i >= 0 && params[:item][:sort_no].to_i <= 99999999999
    else
      self.errors.add :sort_no, "は不正な値です。11桁の整数で登録してください。"
    end

    if params[:item][:name].blank?
      self.errors.add :name, "を登録してください。"
    end

    if admin_groups.empty?
      self.errors.add :"施設管理所属", "を登録してください。"
    end
    if edit_groups.empty?
      self.errors.add :"予約可能所属", "を登録してください。"
    end

    limit_flg = false

    admin_first_gid = gid
    admin_first_gname = ""
    admin_groups.each_with_index{|admin_group, y|
      ad_gid = admin_group[1]
      ad_gname = admin_group[2]
      if y == 0
        admin_first_gid = ad_gid
        admin_first_gname = ad_gname
      end

      limit = Gw::PropOtherLimit.limit_count(ad_gid)
      count = Gw::PropOtherRole.admin_group_count(ad_gid)
      if limit <= count
        limit_flg = true
        ad_gnames << [ad_gname]
      end
    }

    if limit_flg
      self.errors.add :"施設管理所属", "は、設定された上限を超えて登録しようとしています。上限を変更するか、別の所属から施設管理権限を外してください。重複している所属は、#{Gw.join([ad_gnames], '、')}です。"
    end

    self.reserved_state = params[:item][:reserved_state]
    self.sort_no = params[:item][:sort_no]
    self.name    = params[:item][:name]
    self.type_id   = params[:item][:type_id]
    self.comment   = params[:item][:comment]
    self.extra_flag   = params[:item][:extra_flag]
    self.extra_data   = params[:item][:extra_data]

    if mode == :create
      self.creator_uid = uid
      self.updater_uid = uid
      self.created_at = 'now()'
      self.updated_at = 'now()'
    elsif mode == :update
      self.updater_uid = uid
      self.updated_at = 'now()'
    end

    self.gid = admin_first_gid
    self.gname = admin_first_gname

    if self.errors.size == 0 && self.editable? && self.save()
      prop_id = self.id

      Gw::PropOtherRole.destroy_all("prop_id = #{prop_id} and auth = 'admin'")
      admin_groups.each_with_index{|admin_group, y|
        new_admin_group = Gw::PropOtherRole.new()
        new_admin_group.gid = admin_group[1]
        new_admin_group.prop_id = prop_id
        new_admin_group.auth = 'admin'
        new_admin_group.created_at = 'now()'
        new_admin_group.updated_at = 'now()'
        new_admin_group.save
      }

      old_edit_groups = Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'edit'")
      old_edit_groups.each_with_index{|old_edit_role, x|
        use = 0
        edit_groups.each_with_index{|edit_group, y|
          if old_edit_role.gid.to_s == edit_group[1].to_s
              edit_groups.delete_at(y)
              use = 1
          end
        }
        if use == 0
          old_edit_role.destroy
        end
      }
      edit_groups.each_with_index{|edit_group, y|
        new_edit_role = Gw::PropOtherRole.new()
        new_edit_role.gid = edit_group[1]
        new_edit_role.prop_id = prop_id
        new_edit_role.auth = 'edit'
        new_edit_role.created_at = 'now()'
        new_edit_role.updated_at = 'now()'
        new_edit_role.save
      }

      old_read_groups = Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'read'")
      old_read_groups.each_with_index{|old_role, x|
        use = 0
        read_groups.each_with_index{|read_group, y|
          if old_role.gid.to_s == read_group[1].to_s
            read_groups.delete_at(y)
            use = 1
          end
        }
        if use == 0
          old_role.destroy
        end
      }
      read_groups.each_with_index{|read_group, y|
        new_role = Gw::PropOtherRole.new()
        new_role.gid = read_group[1]
        new_role.prop_id = prop_id
        new_role.auth = 'read'
        new_role.created_at = 'now()'
        new_role.updated_at = 'now()'
        new_role.save
      }
    end

  end

  private

  def corrected_group_id_and_names(roles)
    roles.map do |role|
      gname = ''
      disabled = false
      if role.gid == 0
        gname = "制限なし"
      else
        if (g = role.group || role.group_history)
          disabled = true if g.state == 'disabled'
          gname = g.name
        else
          disabled = true
          gname = "*削除所属 (gid=#{role.gid})"
        end
      end
      [role.gid, gname, disabled]
    end
  end

  def corrected_group_options(roles)
    corrected_group_id_and_names(roles).map {|gid, gname, disabled|
      ["", gid, gname] unless disabled
    }.compact
  end

  def corrected_group_names(roles)
    corrected_group_id_and_names(roles).map {|_, gname, disabled|
      disabled ? %(<span style="color:red;">#{gname}</span>) : gname
    }
  end
end
