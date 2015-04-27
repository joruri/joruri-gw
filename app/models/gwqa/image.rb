class Gwqa::Image < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Image::Base
  include Gwqa::Model::Systemname

  belongs_to :doc, :foreign_key => :parent_id
  belongs_to :control, :foreign_key => :title_id
  belongs_to :db_file, :foreign_key => :db_file_id, :dependent => :destroy
end
