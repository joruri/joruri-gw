class Gw::MemoUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  belongs_to :memo, :foreign_key => :schedule_id, :class_name => 'Gw::Memo'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
end
