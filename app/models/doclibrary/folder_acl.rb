class Doclibrary::FolderAcl < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::SerialNo
  include Gwboard::Model::FolderAcl::Auth

  belongs_to :folder, :foreign_key => :folder_id
end
