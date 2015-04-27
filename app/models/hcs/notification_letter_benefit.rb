class Hcs::NotificationLetterBenefit < Hcs::NotificationDatabase
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :letter, :foreign_key => :parent_id, :class_name => 'Hcs::NotificationLetter'
end
