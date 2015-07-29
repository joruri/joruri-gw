# encoding: utf-8
class Gw::PropType < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  
  validates_presence_of :name, :sort_no
end
