class Pes::Database < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :pes rescue nil
end
