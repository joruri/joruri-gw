module Concerns::System::CustomGroup::Role
  extend ActiveSupport::Concern

  included do
    attr_accessor :selected_admin_group_ids, :selected_admin_user_ids
    attr_accessor :selected_edit_group_ids, :selected_edit_user_ids
    attr_accessor :selected_read_group_ids, :selected_read_user_ids
    before_save :build_custom_group_roles
  end

  def admin_group_roles
    custom_group_role.select{|r| r.class_id == 2 && r.priv_name == 'admin'}
  end

  def edit_group_roles
    custom_group_role.select{|r| r.class_id == 2 && r.priv_name == 'edit'}
  end

  def read_group_roles
    custom_group_role.select{|r| r.class_id == 2 && r.priv_name == 'read'}
  end

  def admin_user_roles
    custom_group_role.select{|r| r.class_id == 1 && r.priv_name == 'admin'}
  end

  def edit_user_roles
    custom_group_role.select{|r| r.class_id == 1 && r.priv_name == 'edit'}
  end

  def read_user_roles
    custom_group_role.select{|r| r.class_id == 1 && r.priv_name == 'read'}
  end

  def selected_admin_group_options
    self.selected_admin_group_ids ||= admin_group_roles.map(&:group_id)
    load_group_options(selected_admin_group_ids)
  end

  def selected_edit_group_options
    self.selected_edit_group_ids ||= edit_group_roles.map(&:group_id)
    load_group_options(selected_edit_group_ids)
  end

  def selected_read_group_options
    self.selected_read_group_ids ||= read_group_roles.map(&:group_id)
    load_group_options(selected_read_group_ids)
  end

  def selected_admin_user_options
    self.selected_admin_user_ids ||= self.new_record? ? Core.user.id : admin_user_roles.map(&:user_id)
    load_user_options(selected_admin_user_ids)
  end

  def selected_edit_user_options
    self.selected_edit_user_ids ||= self.new_record? ? Core.user.id : edit_user_roles.map(&:user_id)
    load_user_options(selected_edit_user_ids)
  end

  def selected_read_user_options
    self.selected_read_user_ids ||= self.new_record? ? Core.user.id : read_user_roles.map(&:user_id)
    load_user_options(selected_read_user_ids)
  end

  private

  def load_group_options(ids)
    System::Group.select(:id, :code, :name).where(id: ids).order(sort_no: :asc, code: :asc).map{|g| [g.ou_name, g.id]}
  end

  def load_user_options(ids)
    System::User.select(:id, :code, :name).where(id: ids).order(sort_no: :asc, code: :asc).map{|u| [u.display_name, u.id]}
  end

  def build_custom_group_roles
    return unless selected_admin_group_ids

    self.selected_admin_group_ids = selected_admin_group_ids.reject(&:blank?).map(&:to_i)
    self.selected_edit_group_ids = selected_edit_group_ids.reject(&:blank?).map(&:to_i)
    self.selected_read_group_ids = selected_read_group_ids.reject(&:blank?).map(&:to_i)
    self.selected_admin_user_ids = selected_admin_user_ids.reject(&:blank?).map(&:to_i)
    self.selected_edit_user_ids = selected_edit_user_ids.reject(&:blank?).map(&:to_i)
    self.selected_read_user_ids = selected_read_user_ids.reject(&:blank?).map(&:to_i)

    build_custom_group_roles_for_group('admin', selected_admin_group_ids)
    build_custom_group_roles_for_group('edit', selected_edit_group_ids)
    build_custom_group_roles_for_group('read', selected_read_group_ids)
    build_custom_group_roles_for_user('admin', selected_admin_user_ids)
    build_custom_group_roles_for_user('edit', selected_edit_user_ids)
    build_custom_group_roles_for_user('read', selected_read_user_ids)
  end

  def build_custom_group_roles_for_group(priv_name, selected_gids)
    roles = custom_group_role.select {|r| r.priv_name == priv_name && r.class_id == 2}
    current_gids = roles.map(&:group_id)
    new_gids = selected_gids - current_gids
    del_gids = current_gids - selected_gids
    new_gids.each {|gid| custom_group_role.build(priv_name: priv_name, class_id: 2, group_id: gid) }
    roles.select {|r| del_gids.include?(r.group_id) }.each(&:mark_for_destruction)
  end

  def build_custom_group_roles_for_user(priv_name, selected_uids)
    roles = custom_group_role.select {|r| r.priv_name == priv_name && r.class_id == 1}
    current_uids = roles.map(&:user_id)
    new_uids = selected_uids - current_uids
    del_uids = current_uids - selected_uids
    new_uids.each {|uid| custom_group_role.build(priv_name: priv_name, class_id: 1, user_id: uid) }
    roles.select {|r| del_uids.include?(r.user_id) }.each(&:mark_for_destruction)
  end
end
