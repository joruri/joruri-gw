class Gwfaq::Category < Gwboard::CommonDb
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  include Gwboard::Model::SerialNo
  include Gwfaq::Model::Systemname

  acts_as_tree order: { sort_no: :asc }

  belongs_to :control, :foreign_key => :title_id

  validates :state, :sort_no, :name, presence: true

  def is_deletable?
    !Gwfaq::Doc.where(category1_id: self.id).exists?
  end
end
