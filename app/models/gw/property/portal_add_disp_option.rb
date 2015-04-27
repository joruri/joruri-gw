class Gw::Property::PortalAddDispOption < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, uid: "portal_add", name: "portal_disp_option", type_name: "json" }
  end

  def default_options
    Array.new(3, ['closed'])
  end

  def self.display_right?
    first_or_new.options_value[2][0] == 'opened'
  end
end
