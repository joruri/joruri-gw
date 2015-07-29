# encoding: utf-8
class System::Sequence < ActiveRecord::Base
  self.table_name = "system_sequences"

  scope :versioned, lambda{ |v| { :conditions => ["version = ?", "#{v}"] }}
end
