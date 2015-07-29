# encoding: utf-8
class System::Commitment < ActiveRecord::Base
  include System::Model::Base

  validates_presence_of :version, :name, :value

  def value_to_hash
    _attributes = {}

    xml = REXML::Document.new(value)
    xml[1].each_child do |c|
      eval("_attributes[:#{c.name}] = c.text")
    end

    _attributes
  end

  def rollback(item)
    new_attr = value_to_hash
    eval("new_attr.delete(:#{item.class.primary_key})")
    item.attributes = new_attr
    item.save
  end
end
