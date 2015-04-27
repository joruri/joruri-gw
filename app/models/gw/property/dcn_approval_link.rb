class Gw::Property::DcnApprovalLink < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: "dcn_approval", type_name: "xmllink" }
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
end
