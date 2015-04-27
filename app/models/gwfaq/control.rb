class Gwfaq::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Gwfaq::Model::Systemname
  include System::Model::Base::Status

  #has_many :adm, :foreign_key => :title_id, :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs, :foreign_key => :title_id, :dependent => :destroy
  has_many :categories, :foreign_key => :title_id, :dependent => :destroy
  has_many :files, :foreign_key => :title_id

  validates :state, :title, presence: true
  validates :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :monthly_view_line,  
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def display_category1_name
    category1_name.presence || '分類'
  end

  def categorys_path
    return self.item_home_path + "categories?title_id=#{self.id}"
  end

  def docs_path
    return self.item_home_path + "docs?title_id=#{self.id}&limit=#{self.default_limit}"
  end

  def adm_docs_path
    return self.item_home_path + "adms?title_id=#{self.id}&limit=#{self.default_limit}"
  end
end
