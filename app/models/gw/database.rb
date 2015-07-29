# -*- encoding: utf-8 -*-
class Gw::Database < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :dev_jgw_gw rescue nil
end
