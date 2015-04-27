class Gw::Property::PortalMode < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: 'portal', type_name: 'mode' }
  end

  def default_options
    2
  end

  def encode(value)
    value.to_s
  end

  def decode
    options.to_i
  end

  def mode_options
    [["通常時",2],["災害時",3]]
  end

  def mode_label
    mode_options.rassoc(options_value).try(:first)
  end

  def normal_mode?
    options_value == 2
  end

  def disaster_mode?
    options_value == 3
  end

  def self.is_disaster_admin?(user = Core.user)
    user.has_role?('disaster_admin/admin')
  end

  def self.is_disaster_editor?(user = Core.user)
    user.has_role?('disaster_admin/editor')
  end
end
