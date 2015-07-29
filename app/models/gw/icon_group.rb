# -*- encoding: utf-8 -*-
class Gw::IconGroup < Gw::Database
  include System::Model::Base

  include Cms::Model::Base::Content

  has_many :gw_icons

end
