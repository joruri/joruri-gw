# encoding: utf-8
class System::Unid < ActiveRecord::Base
  include System::Model::Base

  validates_presence_of :module, :item_type, :item_id
end
