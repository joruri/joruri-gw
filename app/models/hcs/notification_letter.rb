class Hcs::NotificationLetter < Hcs::NotificationDatabase
  include System::Model::Base
  include System::Model::Base::Content

  has_many  :benefit, :foreign_key => :parent_id, :class_name => 'Hcs::NotificationLetterBenefit', :dependent=>:destroy
  has_many  :deduction, :foreign_key => :parent_id, :class_name => 'Hcs::NotificationLetterDeduction', :dependent=>:destroy
end
