class Gw::AdminCheckExtension < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Id

  validates :state, presence: true
  validates :extension, uniqueness: { scope: :deleted_at }, 
    format: { with: /\A[0-9A-Za-z]+\z/, message: "は半角英数字で入力してください。" }
  validates :sort_no, numericality: true

  default_scope { where.not(:state => 'deleted') }

  def states
    [['有効','enabled'],['無効','disabled']]
  end

  def state_label
    states.rassoc(state).try(:first)
  end

  def self.enabled_extensions
    self.where(:state => 'enabled').order(:state, :sort_no, :updated_at => :desc).pluck(:extension)
  end
end
