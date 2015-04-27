class Gw::PropOtherLimit < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :group, :foreign_key => 'gid', :class_name => 'System::Group'

  validates :gid, uniqueness: true
  validates :limit, presence: true
  validates :limit, numericality: { greater_than_or_equal_to: 20, less_than_or_equal_to: 100000 }

  def self.limit_count(gid = Core.user_group.id)
    self.where(gid: gid).first.try(:limit).presence || 20
  end
end
