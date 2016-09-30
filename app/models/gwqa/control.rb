class Gwqa::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Operator
  include Gwboard::Model::Control::Base
  include Gwboard::Model::Control::Auth
  include Gwqa::Model::Systemname
  include System::Model::Base::Status
  include Util::ValidateScript

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

  validates_each :other_system_link, :banner, :left_banner, :caption  do |record, attr, value|
    record.errors.add(attr, "にスクリプトは利用できません。") if record.check_script(value)
  end

  def display_category1_name
    category1_name.presence || '分類'
  end

  def gwqa_question_new_path
    return item_home_path + "question_posts/new/?title_id=#{self.id}"
  end

  def gwqa_preview_index_path
    return item_home_path + "qa_previews/"
  end

  def _qa_admin_queston_path
    return item_home_path + "questions?title_id=#{self.id}"
  end

  def _qa_admin_answer_path
    return item_home_path + "answers?title_id=#{self.id}"
  end

  def _qa_control_queston_path
    return item_home_path + 'question_posts/'
  end

  def categorys_path
    return self.item_home_path + "categories?title_id=#{self.id}"
  end

  def posts_path
    return self.item_home_path + "posts?title_id=#{self.id}"
  end

  def recognize_posts_path
    return self.item_home_path + "recognize_posts?title_id=#{self.id}"
  end

  def docs_path
    return self.item_home_path + "docs?title_id=#{self.id}&limit=#{self.default_limit}"
  end

  def item_path
    return "#{Site.current_node.public_uri}"
  end

  def show_path
    return "#{Site.current_node.public_uri}#{self.id}/"
  end

  def edit_path
    return "#{Site.current_node.public_uri}#{self.id}/edit"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}/update"
  end

end
