class System::GroupChangeDate < ActiveRecord::Base

  include System::Model::Base
  include System::Model::Base::Config

  validates :start_at,              :presence => true

end
