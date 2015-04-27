class Questionnaire::Property::HelpLink < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, uid: '0', name: "enquete", type_name: "help_link" }
  end

  def default_options
    Array.new(7, [''])
  end
end
