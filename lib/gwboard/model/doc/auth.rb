module Gwboard::Model::Doc::Auth
  extend ActiveSupport::Concern

  included do
    scope :group_or_creater_docs, ->(user = Core.user) {
      where([
        arel_table[:section_code].eq(user.first_group_code), 
        arel_table[:creater_id].eq(user.code)
      ].reduce(:or))
    }
    scope :group_or_recognizer_docs, ->(user = Core.user) {
      joins(:recognizers).where([
        arel_table[:section_code].eq(user.first_group_code), 
        arel_table[:creater_id].eq(user.code),
        recognizer_klass.arel_table[:code].eq(user.code)
      ].reduce(:or))
    }
    scope :in_public_folder, -> {
      joins(:folder).where(folder_klass.arel_table[:state].eq('public'))
    }
    scope :in_readable_folder, ->(user = Core.user) {
      joins(:folder_acls).merge(folder_acl_klass.with_user_or_groups(user))
    }
    scope :with_readable_role, ->(user = Core.user) {
      joins(:roles).merge(role_klass.with_user_or_groups(user, "r/w"))
    }
    scope :satisfy_restrict_access, ->(user = Core.user) { 
      joins(:control).where([
        control_klass.arel_table[:restrict_access].eq(0),
        control_klass.arel_table[:restrict_access].eq(1).and( arel_table[:section_code].eq(user.first_group_code) )
      ].reduce(:or))
    }
  end

  def is_editable?(user = Core.user)
    return @is_editable if defined? @is_editable
    @is_editable = control.is_admin? || 
      (control.is_writable?(user) && (section_code.in?(user.groups_and_ancestors_codes) || creater_id == user.code))
  end

  def is_recognizable?(user = Core.user)
    return @is_recognizable if defined? @is_recognizable
    @is_recognizable = recognizers.with_user(user).exists?
  end

  def is_publishable?(user = Core.user)
    return @is_publishable if defined? @is_publishable
    @is_publishable = control.is_admin?(user) || section_code == user.first_group_code
  end
end
