module Gwboard::Model::Control::Auth
  extend ActiveSupport::Concern

  included do
    with_options if: "admingrps_json.present? && adms_json.present?" do |f|
      f.after_save :save_adms
      f.after_save :update_dsp_admin_name
    end
    after_save :save_editors, if: "editors_json.present?"
    after_save :save_sueditors, if: "sueditors_json.present?"
    after_save :save_readers, if: "readers_json.present?"
    after_save :save_sureaders, if: "sureaders_json.present?"
    
    validate :validate_json_columns
    scope :with_readable_role, ->(user = Core.user) {
      joins(:role).merge(reflect_on_association(:role).klass.with_user_or_groups(user, "r/w"))
    }
    scope :with_admin_role, ->(user = Core.user) {
      joins(:role).merge(reflect_on_association(:role).klass.with_user_or_groups(user, "a"))
    }
  end

  def group_roles_with_admin
    role.select{|r| r.group_role? && r.admin_role?}
  end

  def user_roles_with_admin
    role.select{|r| r.user_role? && r.admin_role?}
  end

  def group_roles_with_write
    role.select{|r| r.group_role? && r.write_role?}
  end

  def user_roles_with_write
    role.select{|r| r.user_role? && r.write_role?}
  end

  def group_roles_with_read
    role.select{|r| r.group_role? && r.read_role?}
  end

  def user_roles_with_read
    role.select{|r| r.user_role? && r.read_role?}
  end

  def admingrps_json_value
    JSON.parse(admingrps_json) rescue []
  end

  def adms_json_value
    JSON.parse(adms_json) rescue []
  end

  def editors_json_value
    JSON.parse(editors_json) rescue []
  end

  def sueditors_json_value
    JSON.parse(sueditors_json) rescue []
  end

  def readers_json_value
    JSON.parse(readers_json) rescue []
  end

  def sureaders_json_value
    JSON.parse(sureaders_json) rescue []
  end

  def board_role_for?(user = Core.user, role_code = 'a/w/r')
    role.with_user_or_groups(user, role_code).exists?
  end

  def is_sysadm?(user = Core.user)
    return @is_sysadm if defined? @is_sysadm
    @is_sysadm = user.has_role?("_admin/admin", "#{self.class.namespace}/admin")
  end

  def is_bbsadm?(user = Core.user)
    return @is_bbsadm if defined? @is_bbsadm
    @is_bbsadm = board_role_for?(user, 'a')
  end

  def is_admin?(user = Core.user)
    return @is_admin if defined? @is_admin
    @is_admin = is_sysadm?(user) || is_bbsadm?(user)
  end

  def is_writable?(user = Core.user)
    return @is_writable if defined? @is_writable
    @is_writable = is_admin?(user) || board_role_for?(user, 'a/w')
  end

  def is_readable?(user = Core.user)
    return @is_readable if defined? @is_readable
    @is_readable = is_admin?(user) || board_role_for?(user, 'a/w/r')
  end

  def display_first_admin_name
    return dsp_admin_name if dsp_admin_name.present?

    admingrps = admingrps_json_value
    return admingrps[0][2] if admingrps[0] && admingrps[0][2]

    adms = adms_json_value
    return adms[0][2] if adms[0] && adms[0][2]
    return ''
  end

  module ClassMethods
    def namespace
      self.to_s.split('::').first.downcase
    end

    def is_sysadm?(user = Core.user)
      user.has_role?("_admin/admin", "#{namespace}/admin")
    end

    def is_admin?(user = Core.user)
      is_sysadm?(user) || is_any_bbsadm?(user)
    end

    def is_any_bbsadm?(user = Core.user)
      "#{namespace.capitalize}::Role".constantize.with_user_or_groups(user, 'a').exists?
    end
  end

  private

  def validate_json_columns
    [:adms_json, :sueditors_json, :sureaders_json].each do |column|
      validate_json_column(column)
    end
  end

  def validate_json_column(column)
    error_user_names = []
    json = read_attribute(column)
    if json.present?
      JSON.parse(json).each do |field|
        user = System::User.find_by(id: field[1])
        if !user || user.state != "enabled"
          error_user_names << field[2]
        end
      end
    end

    if error_user_names.size > 0
      errors.add(column, "の#{error_user_names.join(', ')}は無効になっています。削除するか、または有効なユーザーを選択してください。")
    end
  end

  def save_adms
    role.destroy_all

    admingrps_json_value.each do |group_value|
      create_group_role('a', group_value)
    end
    adms_json_value.each do |user_value|
      create_user_role_for_adm('a', user_value)
    end
  end

  def update_dsp_admin_name
    r = role.select(&:admin_role?).first
    update_columns(dsp_admin_name: r.group_name) if r
  end

  def save_editors
    editors_json_value.each do |group_value|
      create_group_role('w', group_value)
    end
  end

  def save_sueditors
    sueditors_json_value.each do |user_value|
      create_user_role('w', user_value)
    end
  end

  def save_readers
    readers_json_value.each do |group_value|
      create_group_role('r', group_value)
    end
  end

  def save_sureaders
    sureaders_json_value.each do |user_value|
      create_user_role('r', user_value)
    end
  end

  def create_group_role(role_code, group_value)
    if group_value[1].to_s == '0'
      return role.create(role_code: role_code, group_id: 0, group_code: '0', group_name: group_value[2])
    elsif group = System::Group.find_by(id: group_value[1])
      return role.create(role_code: role_code, group_id: group.id, group_code: group.code, group_name: group.name)
    end
  end

  def create_user_role_for_adm(role_code, user_value)
    if user = System::User.find_by(id: user_value[1])
      group = user.groups.first
      return role.create(role_code: role_code, user_id: user.id, user_code: user.code, user_name: user.name_and_code,
        group_id: group.try(:id), group_name: group.try(:name), group_code: group.try(:code))
    end
  end

  def create_user_role(role_code, user_value)
    if user = System::User.find_by(id: user_value[1])
      return role.create(role_code: role_code, user_id: user.id, user_code: user.code, user_name: user.name_and_code)
    end
  end
end
