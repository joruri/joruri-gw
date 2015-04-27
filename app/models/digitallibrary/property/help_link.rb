class Digitallibrary::Property::HelpLink < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: 'digitallibrary', type_name: 'help_link' }
  end

  def default_options
    Array.new(1, [''])
  end

  def wiki_help_link
    options_value.flatten[0]
  end
end
