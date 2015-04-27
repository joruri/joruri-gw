class Gwbbs::Recognizer < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Recognizer::Auth

  belongs_to :doc, :foreign_key => :parent_id
end
