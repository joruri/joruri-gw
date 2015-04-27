class Gwmonitor::Property::TestMailAddress < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, uid: '0', name: "gwmonitor", type_name: "test" }
  end

  def default_options
    ''
  end

  def encode(value)
    value
  end

  def decode
    options
  end
end
