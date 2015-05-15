class Gwworkflow::Control < Gw::Database
  self.table_name = 'gw_workflow_controls'
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Control::Base
  include Gwworkflow::Model::Systemname

  has_many :files, :foreign_key => :title_id

  validates :state, :recognize, :title, :sort_no, presence: true
  validates :default_published, :commission_limit, :doc_body_size_capacity, :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def is_readable?
    true
  end
end
