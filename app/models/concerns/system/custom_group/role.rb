module Concerns::System::CustomGroup::Role
  extend ActiveSupport::Concern

  included do
    attr_accessor :selected_admin_group_ids, :selected_admin_user_ids
    attr_accessor :selected_edit_group_ids, :selected_edit_user_ids
    attr_accessor :selected_read_group_ids, :selected_read_user_ids
    with_options if: :selected_admin_group_ids do |f|
      f.before_validation :set_selected_ids
      f.before_save :build_custom_group_roles
    end
  end

  def admin_group_roles
    custom_group_role.select(&:admin_group_role?)
  end

  def edit_group_roles
    custom_group_role.select(&:edit_group_role?)
  end

  def read_group_roles
    custom_group_role.select(&:read_group_role?)
  end

  def admin_user_roles
    custom_group_role.select(&:admin_user_role?)
  end

  def edit_user_roles
    custom_group_role.select(&:edit_user_role?)
  end

  def read_user_roles
    custom_group_role.select(&:read_user_role?)
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
    self.selected_admin_user_ids ||= default_admin_user_ids
    load_user_options(selected_admin_user_ids)
  end

  def selected_edit_user_options
    self.selected_edit_user_ids ||= default_edit_user_ids
    load_user_options(selected_edit_user_ids)
  end

  def selected_read_user_options
    self.selected_read_user_ids ||= default_read_user_ids
    load_user_options(selected_read_user_ids)
  end

  private

  def default_admin_user_ids
    self.new_record? ? [Core.user.id] : admin_user_roles.map(&:user_id)
  end

  def default_edit_user_ids
    self.new_record? ? [Core.user.id] : edit_user_roles.map(&:user_id)
  end

  def default_read_user_ids
    self.new_record? ? [Core.user.id] : read_user_roles.map(&:user_id)
  end

  def load_group_options(ids)
    load_options_for_model(System::Group, ids).map{|g| [g.ou_name, g.id]}
  end

  def load_user_options(ids)
    load_options_for_model(System::User, ids).map{|u| [u.display_name, u.id]}
  end

  def load_options_for_model(model, ids)
    model.select(:id, :code, :name).where(id: ids).order(sort_no: :asc, code: :asc)
  end

  def set_selected_ids
    %w(admin edit read).each do |priv|
      %w(user group).each do |target|
        ids = send("selected_#{priv}_#{target}_ids")
        ids = ids.reject(&:blank?).map(&:to_i)
        self.send("selected_#{priv}_#{target}_ids=", ids)
      end
    end
  end

  def build_custom_group_roles
    %w(admin edit read).each do |priv|
      %w(user group).each do |target|
        selected_ids = get_selected_ids(priv, target)
        current_ids = get_current_ids(priv, target)

        new_ids = selected_ids - current_ids
        new_ids.each {|id| build_custom_group_role(priv, target, id) }
        del_ids = current_ids - selected_ids
        del_ids.each {|id| destroy_custom_group_role(priv, target, id) }
      end
    end
  end

  def get_selected_ids(priv, target)
    send("selected_#{priv}_#{target}_ids")
  end

  def get_current_ids(priv, target)
    roles = send("#{priv}_#{target}_roles")
    roles.map {|r| r.read_attribute("#{target}_id") }
  end

  def build_custom_group_role(priv, target, id)
    case target
    when 'group'
      custom_group_role.build(priv_name: priv, class_id: 2, group_id: id)
    when 'user'
      custom_group_role.build(priv_name: priv, class_id: 1, user_id: id)
    end
  end

  def destroy_custom_group_role(priv, target, id)
    roles = send("#{priv}_#{target}_roles")
    case target
    when 'group'
      roles = roles.select {|r| r.group_id == id }
    when 'user'
      roles = roles.select {|r| r.user_id == id }
    end
    roles.each(&:mark_for_destruction)
  end
end
