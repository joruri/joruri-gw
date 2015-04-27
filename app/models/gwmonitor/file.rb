class Gwmonitor::File < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname
  include Gwboard::Model::File::Base

  belongs_to :doc, :foreign_key => :parent_id
  belongs_to :control, :foreign_key => :title_id
end
