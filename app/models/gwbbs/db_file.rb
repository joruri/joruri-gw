class Gwbbs::DbFile < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo

  belongs_to :doc, :foreign_key => :parent_id
end
