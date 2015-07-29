# encoding: utf-8
class Gw::PropOtherLimit < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :group , :foreign_key=>'gid' , :class_name=>'System::Group'

  validates_uniqueness_of :gid
  validates_presence_of  :limit
  validates_numericality_of :limit , :greater_than_or_equal_to =>20 , :less_than_or_equal_to=> 100000

  def self.limit_count(gid = Site.user_group.id)

    limit = self.find(:first, :conditions=>"gid = #{gid}")
    count = 20
    if limit.present? && limit.limit.present?
      count = limit.limit
    end
    return count
  end
end
