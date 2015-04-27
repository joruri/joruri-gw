class Gwcircular::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Gwcircular::Model::Systemname

  #has_many :adm, :foreign_key => :title_id, :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs, :foreign_key => :title_id, :dependent => :destroy
  has_many :files, :foreign_key => :title_id

  validates :state, :recognize, :title, :sort_no, presence: true
  validates :default_published, :commission_limit, :doc_body_size_capacity, :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def item_home_path
    return "/gwcircular/"
  end

  def menus_path
    return self.item_home_path
  end

  def custom_groups_path
    return self.item_home_path + "custom_groups/"
  end

  def docs_path
    return self.item_home_path + "docs/"
  end

  def adm_show_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def delete_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def update_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def design_publish_path
    return self.item_home_path + "basics/#{self.id}/design_publish"
  end

  def original_css_file
    return "#{Rails.root}/public/_common/themes/gw/css/option.css"
  end

  def board_css_file_path
    return "#{Rails.root}/public/_attaches/css/#{self.system_name}"
  end

  def board_css_preview_path
    return "#{Rails.root}/public/_attaches/css/preview/#{self.system_name}"
  end

  def default_limit_circular
    [
      ['10行', 10],
      ['20行', 20],
      ['30行', 30],
      ['50行', 50],
      ['100行',100],
      ['150行',150],
      ['200行',200],
      ['250行',250]
    ]
  end
end
