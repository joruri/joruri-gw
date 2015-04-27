module Concerns::Gw::EditTab::PublicRole
  extend ActiveSupport::Concern

  included do
    attr_accessor :selected_public_group_ids
    before_save :build_public_roles
    validate :validate_selected_public_group_ids
  end

  def selected_public_group_options
    self.selected_public_group_ids ||= public_roles.map(&:uid)
    System::Group.where(id: self.selected_public_group_ids).order(sort_no: :asc, code: :asc).map{|g| [g.name, g.id]}
  end

  def public_group_names
    groups = System::Group.arel_table
    public_roles.eager_load(:group).order(groups[:sort_no].asc, groups[:code].asc)
      .map {|r| r.group || r.group_history }.compact.map do |group|
      if group.is_a?(System::GroupHistory)
        %(<span style="color:red;">#{group.name}</span>)
      else
        group.name
      end
    end
  end

  private

  def validate_selected_public_group_ids
    return unless selected_public_group_ids

    self.selected_public_group_ids = selected_public_group_ids.reject(&:blank?).map(&:to_i)
    if self.is_public == 1 && selected_public_group_ids.blank?
      errors.add(:base, '公開所属を選択してください。')
    end
  end

  def build_public_roles
    return unless selected_public_group_ids

    case self.is_public
    when 0, 2
      public_roles.each(&:mark_for_destruction)
    when 1
      current_gids = public_roles.map(&:uid)
      new_gids = selected_public_group_ids - current_gids
      del_gids = current_gids - selected_public_group_ids
      new_gids.each {|gid| public_roles.build(class_id: 2, uid: gid) }
      public_roles.select {|r| del_gids.include?(r.uid) }.each(&:mark_for_destruction)
    end
  end
end
