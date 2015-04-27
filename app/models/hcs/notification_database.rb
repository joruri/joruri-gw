class Hcs::NotificationDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :hcs_notification rescue nil
end
