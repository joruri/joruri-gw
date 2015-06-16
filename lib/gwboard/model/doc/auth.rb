module Gwboard::Model::Doc::Auth
  extend ActiveSupport::Concern

  included do
    scope :group_or_creater_docs, ->(user = Core.user) {
      where([
        arel_table[:section_code].eq(user.groups.first.try(:code)),
        arel_table[:creater_id].eq(user.code)
      ].reduce(:or))
    }
    scope :group_or_recognizer_docs, ->(user = Core.user) {
      joins(:recognizers).where([
        arel_table[:section_code].eq(user.groups.first.try(:code)),
        arel_table[:creater_id].eq(user.code),
        reflect_on_association(:recognizers).klass.arel_table[:code].eq(user.code)
      ].reduce(:or)).distinct
    }
    scope :in_public_folder, -> {
      joins(:folder).where(reflect_on_association(:folder).klass.arel_table[:state].eq('public'))
    }
    scope :in_readable_folder, ->(user = Core.user) {
      joins(:folder_acls).merge(reflect_on_association(:folder_acls).klass.with_user_or_groups(user))
    }
    scope :with_readable_role, ->(user = Core.user) {
      joins(:roles).merge(reflect_on_association(:roles).klass.with_user_or_groups(user, "r/w"))
    }
    scope :satisfy_restrict_access, ->(user = Core.user) {
      controls = reflect_on_association(:control).klass.arel_table
      joins(:control).where([
        controls[:restrict_access].eq(0),
        controls[:restrict_access].eq(1).and( arel_table[:section_code].eq(user.groups.first.try(:code)) )
      ].reduce(:or))
    }
  end

  def is_editable?(user = Core.user)
    return @is_editable if defined? @is_editable
    gcodes = user.groups.map{|g| g.self_and_ancestors.map(&:code)}.flatten
    @is_editable = control.is_admin? || (control.is_writable?(user) && (section_code.in?(gcodes) || creater_id == user.code))
  end

  def is_recognizable?(user = Core.user)
    return @is_recognizable if defined? @is_recognizable
    @is_recognizable = recognizers.with_user(user).exists?
  end

  def is_publishable?(user = Core.user)
    return @is_publishable if defined? @is_publishable
    @is_publishable = control.is_admin?(user) || section_code == user.groups.first.try(:code)
  end
end
