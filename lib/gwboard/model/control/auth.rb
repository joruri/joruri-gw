module Gwboard::Model::Control::Auth
  extend ActiveSupport::Concern

  included do
    after_save :save_adms, :save_roles
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
    JSON.parse(admingrps_json)
  end

  def adms_json_value
    JSON.parse(adms_json)
  end

  def editors_json_value
    JSON.parse(editors_json)
  end

  def sueditors_json_value
    JSON.parse(sueditors_json)
  end

  def readers_json_value
    JSON.parse(readers_json)
  end

  def sureaders_json_value
    JSON.parse(sureaders_json)
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
    return if self.admingrps_json.blank? || self.adms_json.blank?

    role.destroy_all

    dsp_admin_name = nil
    admingrps_json_value.each do |group|
      if (g = System::Group.find_by(id: group[1]))
        role.create(role_code: 'a', group_id: g.id, group_code: g.code, group_name: g.name)
        dsp_admin_name ||= g.name
      end
    end
    adms_json_value.each do |user|
      if (u = System::User.find_by(id: user[1]))
        role.create(role_code: 'a', user_id: u.id, user_code: u.code, user_name: u.name_and_code,
          group_id: u.groups.first.try(:id), group_name: u.groups.first.try(:name), group_code: u.groups.first.try(:code))
        dsp_admin_name ||= u.groups[0].try(:name)
      end
    end

    update_columns(dsp_admin_name: dsp_admin_name)
  end

  def save_roles
    return if self.editors_json.blank? || self.sueditors_json.blank?
    return if self.readers_json.blank? || self.editors_json.blank?

    editors_json_value.each do |group|
      if group[1].to_s == '0'
        role.create(role_code: 'w', group_id: 0, group_code: '0', group_name: group[2])
      elsif (g = System::Group.find_by(id: group[1]))
        role.create(role_code: 'w', group_id: g.id, group_code: g.code, group_name: g.name)
      end
    end
    sueditors_json_value.each do |user|
      if (u = System::User.find_by(id: user[1]))
        role.create(role_code: 'w', user_id: u.id, user_code: u.code, user_name: u.name_and_code)
      end
    end

    readers_json_value.each do |group|
      if group[1].to_s == '0'
        role.create(role_code: 'r', group_id: 0, group_code: '0', group_name: group[2])
      elsif (g = System::Group.find_by(id: group[1]))
        role.create(role_code: 'r', group_id: g.id, group_code: g.code, group_name: g.name)
      end
    end
    sureaders_json_value.each do |user|
      if (u = System::User.find_by(id: user[1]))
        role.create(role_code: 'r', user_id: u.id, user_code: u.code, user_name: u.name_and_code)
      end
    end
  end
end
