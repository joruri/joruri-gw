class Doclibrary::Adm < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Adm::Auth

  belongs_to :control, :foreign_key => :title_id
  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'
end
