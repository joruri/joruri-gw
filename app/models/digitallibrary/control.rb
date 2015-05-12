class Digitallibrary::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Digitallibrary::Model::Systemname
  include System::Model::Base::Status

  #has_many :adm, :foreign_key => :title_id, :dependent => :destroy
  has_many :role, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs, -> { where(doc_type: 1) }, :foreign_key => :title_id, :dependent => :destroy
  has_many :folders, -> { where(doc_type: 0) }, :foreign_key => :title_id, :dependent => :destroy
  has_many :docs_and_folders, :foreign_key => :title_id, :class_name => 'Digitallibrary::Doc'
  has_many :files, :foreign_key => :title_id

  after_save :set_root_folder
  after_update :update_docs_and_folders_seq_name

  validates :state, :recognize, :title, presence: true
  validates :category1_name, :separator_str1, :separator_str2, presence: true
  validates :upload_graphic_file_size_capacity, :upload_document_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max, 
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def categorys_path
    return "#{self.item_home_path}categories?title_id=#{self.id}"
  end

  def new_uploads_path
    return "#{self.item_home_path}docs/new?title_id=#{self.id}"
  end

  def docs_path
    return "#{self.item_home_path}docs?title_id=#{self.id}"
  end

  def adm_docs_path
    return "#{self.item_home_path}adms?title_id=#{self.id}"
  end

  def sort_name_display_states
    {'0' => '表示する', '1' => '表示しない'}
  end

  def date_index_display_states
    {'0' => '使用する', '1' => '使用しない'}
  end

  class << self
    def wallpapers
      Gw::Icon.joins(:icon_group).where(gw_icon_groups: {name: 'digitallibrary'}).order(idx: :asc)
    end
  end

  private

  def set_root_folder
    if root = folders.root
      root.update_columns(
        :updated_at => Time.now,
        :doc_type => 0,
        :title => self.category1_name
      )
    else
      folders.create(
        :state => 'public',
        :title_id => self.id,
        :parent_id => nil,
        :doc_type => 0,
        :sort_no => 0,
        :level_no => 1,
        :title => self.category1_name
      )
    end
  end

  def update_docs_and_folders_seq_name
    if separator_str1_changed? || separator_str2_changed?
      folders.root.update_seq_name_for_descendants
    end
  end
end
