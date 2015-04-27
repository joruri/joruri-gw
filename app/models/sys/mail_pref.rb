class Sys::MailPref < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :mailcore rescue nil
end
