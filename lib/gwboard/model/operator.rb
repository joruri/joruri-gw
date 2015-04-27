module Gwboard::Model::Operator
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_setting_creater_editor
    before_save :set_creater_editor
  end

private

  def control_related?
    self.class.reflect_on_association(:control).present?
  end

  def set_creater_editor(options = {force_create: false, force_admin: false})
    return if self.skip_setting_creater_editor
    return if self.state == 'preparation'

    if self.createdate.blank? || options[:force_create]
      self.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
      self.creater_id = Core.user.code
      self.creater = Core.user.name
      self.createrdivision = Core.user_group.name
      self.createrdivision_id = Core.user_group.code

      self.editor_id = Core.user.code
      self.editordivision_id = Core.user_group.code

      self.creater_admin = options[:force_admin] || (control_related? && control.is_admin?) if self.has_attribute?(:creater_admin)
      self.editor_admin = options[:force_admin] || (control_related? && control.is_admin?) if self.has_attribute?(:editor_admin)
    else
      self.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      self.editor_id = Core.user.code
      self.editor = Core.user.name
      self.editordivision = Core.user_group.name
      self.editordivision_id = Core.user_group.code

      self.editor_admin = options[:force_admin] || (control_related? && control.is_admin?) if self.has_attribute?(:editor_admin)
    end

    true
  end
end
