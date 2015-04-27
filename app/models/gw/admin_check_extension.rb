class Gw::AdminCheckExtension < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates :state, presence: true
  validates :extension, uniqueness: { scope: :deleted_at }, 
    format: { with: /\A[0-9A-Za-z]+\z/, message: "は半角英数字で入力してください。" }
  validates :sort_no, numericality: true

  before_create :set_creator
  before_update :set_updator

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

private

  def set_creator
    self.created_uid = Core.user.id
    self.created_gid = Core.user_group.id
  end

  def set_updator
    self.updated_uid = Core.user.id
    self.updated_gid = Core.user_group.id
  end
end
