class Gwboard::Property::PortalBbsLink < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "smartphone_portal_board" }
  end

  def default_options
    ''
  end

  def encode(value)
    value.to_s
  end

  def decode
    options.to_s
  end

  def self.bbs_links(type_name = "bbs")
    self.where(type_name: type_name).map(&:options_value).map(&:to_i)
  end
end
