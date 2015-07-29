# -*- encoding: utf-8 -*-
class Gwsub::Sb04YearCopyLog < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  def self.create_log(type, origin_fyear_id, origin_section_id, destination_fyear_id, destination_section_id)
    item = self.new
    item.type = type
    origin_section       = Gwsub::Sb04section.find_by_id(origin_section_id)
    destination_section  = Gwsub::Sb04section.find_by_id(destination_section_id)
    item.origin_fyear_id        = origin_fyear_id
    item.origin_section_id      = origin_section_id
    item.origin_section_code    = origin_section.code unless origin_section.blank?
    item.origin_section_name    = origin_section.name unless origin_section.blank?
    item.destination_fyear_id          = destination_fyear_id
    item.destination_section_id        = destination_section_id
    item.destination_section_code      = destination_section.code unless destination_section.blank?
    item.destination_section_name      = destination_section.name unless destination_section.blank?
    item.created_user   = Site.user.name
    item.created_group  = Site.user_group.code+Site.user_group.name
    item.created_at     = Time.now
    item.save(:validate=>false)
  end
end
