class Gwmonitor::File < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile
  
  before_create :before_create
  after_create :after_create
  after_destroy :after_destroy
end
