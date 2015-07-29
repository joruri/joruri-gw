# encoding: utf-8
class System::Task < ActiveRecord::Base
  include System::Model::Base

  has_one :unid_data, :primary_key => :unid, :foreign_key => :id, :class_name => 'System::Unid'
end
