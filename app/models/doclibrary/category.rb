class Doclibrary::Category < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwboard::Model::SerialNo
  include Gwboard::Model::Operator
  include Doclibrary::Model::Systemname

  acts_as_tree order: { sort_no: :asc }

  has_many :docs, :foreign_key => :category2_id
  has_many :files, :foreign_key => :parent_id
  belongs_to :control, :foreign_key => :title_id

  validates :state, presence: true
  with_options unless: :state_preparation? do |f|
    f.validates :wareki, presence: true
    f.validates :nen, presence: true
    f.validates :gatsu, presence: true
    f.validates :sono, presence: true
  end

  def state_preparation?
    state == 'preparation'
  end

  def wiki_enabled?
    false
  end

  def display_files
    files
  end

  def link_list_path
    return "/doclibrary/categories?parent_id=#{self.id}&title_id=#{self.title_id}"
  end

  def item_path
    return "/doclibrary/categories?title_id=#{self.title_id}"
  end

  def show_path
    return "/doclibrary/categories/#{self.id}?title_id=#{self.title_id}"
  end

  def edit_path
    return "/doclibrary/categories/#{self.id}/edit?title_id=#{self.title_id}"
  end

  def delete_path
    return "/doclibrary/categories/#{self.id}?title_id=#{self.title_id}"
  end

  def update_path
    return "/doclibrary/categories/#{self.id}?title_id=#{self.title_id}"
  end
end
