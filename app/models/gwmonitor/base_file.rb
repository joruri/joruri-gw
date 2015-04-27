class Gwmonitor::BaseFile < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::File::Base

  belongs_to :control, :foreign_key => :title_id

  def system_name
    return 'gwmonitor_base'
  end

  def file_base_path
    return "/_attaches/#{self.system_name}"
  end
end
