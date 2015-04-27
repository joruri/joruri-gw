class System::GroupChangeDate < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  validates :start_at, :presence => true
end
