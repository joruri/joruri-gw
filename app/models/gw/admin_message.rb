class Gw::AdminMessage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates :state, :sort_no, :body, :mode, presence: true
  validates :sort_no, numericality: true
  validates :body, length: { maximum: 10000 }

  validate :check_script_body

  def check_script_body
    if body.present? && body =~ /script/
      errors.add(:body, "にスクリプトは利用できません。")
    end
  end

  def modes
    [['いつも',1], ['通常時',2], ['災害時',3]]
  end

  def mode_label
    modes.rassoc(mode).try(:first)
  end

  def state_label
    self.class.state_select.rassoc(state).try(:first)
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def self.state_select
    [['する',1],['しない',2]]
  end

  def self.state_show(state)
    state_select.rassoc(state).try(:first)
  end
end
