class Gwmonitor::BaseFile < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile
  
  before_create :before_create
  after_create :after_create
  after_destroy :after_destroy
  
  def system_name
    return 'gwmonitor_base'
  end
  def file_base_path
    return "/_attaches/#{self.system_name}"
  end

end
