class Gw::ReminderExternal < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :system, :data_id, :title, :updated, :link, :author, :contributor, :member
  validates_uniqueness_of :data_id, :scope => [:system, :member, :deleted_at]
end
