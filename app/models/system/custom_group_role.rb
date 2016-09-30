class System::CustomGroupRole < ActiveRecord::Base
  self.primary_key = :rid
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :custom_group, :foreign_key => :custom_group_id, :class_name => 'System::CustomGroup'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'
  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'

  scope :with_user_or_group, ->(user, priv_name) {
    where(arel_table[:priv_name].eq(priv_name)).where([
      [arel_table[:class_id].eq(1), arel_table[:user_id].eq(user.id)].reduce(:and),
      [arel_table[:class_id].eq(2), arel_table[:group_id].in(user.groups.first.try(:id))].reduce(:and)
    ].reduce(:or))
  }

  def admin_role?
    priv_name == 'admin'
  end

  def edit_role?
    priv_name == 'edit'
  end

  def read_role?
    priv_name == 'read'
  end

  def user_role?
    class_id == 1
  end

  def group_role?
    class_id == 2
  end

  def editable?(cgid, gid, uid)
    self.class.where("custom_group_id = #{cgid} and ( (class_id = 2 and group_id = #{gid}) or (class_id = 1 and user_id = #{uid}) ) and priv_name = 'edit' ").exists?
  end
end
