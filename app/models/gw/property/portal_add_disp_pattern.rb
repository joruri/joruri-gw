class Gw::Property::PortalAddDispPattern < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, uid: "portal_add", name: "portal_disp_pattern", type_name: "json" }
  end

  def default_options
    1
  end

  def encode(value)
    value.to_s
  end

  def decode
    options.to_i
  end
end
