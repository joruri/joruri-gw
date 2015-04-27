module Gwsub::Admin::Sb06::Sb06AssignedConferencesHelper

  def get_sb06_conference_kind_id(kind_id, conf_items, fy_id)
    return kind_id if kind_id.to_i == 0
    return kind_id if conf_items.blank?
    is_exist = false
    conf_items.each do |conf|
      is_exist = true if conf[1].to_i == kind_id
    end
    unless is_exist
      conf_kind  =  Gwsub::Sb06AssignedConfKind.find(kind_id)
      unless conf_kind.blank?
        #conf_kind_code
        #pre_conf_kind  =  Gwsub::Sb06AssignedConfKind.find(:first,
        # :conditions=>["fyear_id = ? and conf_kind_code = ?", fy_id, conf_kind.conf_kind_code])
        pre_conf_kind = Gwsub::Sb06AssignedConfKind.where("fyear_id = ? and conf_kind_code = ?", fy_id, conf_kind.conf_kind_code).first
        kind_id =  pre_conf_kind.id unless pre_conf_kind.blank?
      end
    end
    return kind_id
  end

end
