class System::GroupNext < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree

  belongs_to   :group_update , :foreign_key => :group_update_id  , :class_name => 'System::GroupUpdate'
  belongs_to   :old_g        , :foreign_key => :old_group_id     , :class_name => 'System::Group'

  validates_uniqueness_of :old_group_id ,:message=>"は、すでに割当済です。"

  before_save :before_save_set_column

  def before_save_set_column
    if self.old_group_id.to_i== 0
    else
      self.old_parent_id = self.old_g.parent_id
      self.old_name = self.old_g.name
      self.old_code = self.old_g.code
    end
  end
end
