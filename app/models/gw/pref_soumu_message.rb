class Gw::PrefSoumuMessage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Util::ValidateScript

  validates :state, :tab_keys, :sort_no, :body, presence: true
  validates :tab_keys, numericality: true
  validates :sort_no, numericality: true

  validate :check_script_body

  def check_script_body
    errors.add(:body, "にスクリプトは利用できません。") if check_script(body)
  end


  def self.state_select
    [['する',1],['しない',2]]
  end

  def state_label
    self.class.state_select.rassoc(state).try(:first)
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('_admin/developer')
  end

  def self.is_editor?(user = Core.user)
    user.has_role?('pref_soumu_msg/editor')
  end
end
