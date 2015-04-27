class Gw::Property::PortalDisasterBbs < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: 'portal', type_name: 'disaster_bbs' }
  end

  def default_options
    nil
  end

  def encode(value)
    value.to_s
  end

  def decode
    options.to_i
  end

  def bbs_options
    Gwbbs::Control.where(state: 'public').order(:sort_no)
  end

  def bbs_label
    Gwbbs::Control.find_by(id: options_value).try(:title)
  end
end
