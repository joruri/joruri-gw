class Gwsub::Sb04YearCopyLog < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  def self.create_log(type, origin_fyear_id, origin_section_id, destination_fyear_id, destination_section_id)
    item = self.new
    item.type = type
    origin_section       = Gwsub::Sb04section.where(:id =>origin_section_id).first
    destination_section  = Gwsub::Sb04section.where(:id =>destination_section_id).first
    item.origin_fyear_id        = origin_fyear_id
    item.origin_section_id      = origin_section_id
    item.origin_section_code    = origin_section.code unless origin_section.blank?
    item.origin_section_name    = origin_section.name unless origin_section.blank?
    item.destination_fyear_id          = destination_fyear_id
    item.destination_section_id        = destination_section_id
    item.destination_section_code      = destination_section.code unless destination_section.blank?
    item.destination_section_name      = destination_section.name unless destination_section.blank?
    item.created_user   = Core.user.name
    item.created_group  = Core.user_group.code+Core.user_group.name
    item.created_at     = Time.now
    item.save(:validate=>false)
  end
end
