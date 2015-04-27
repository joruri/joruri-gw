class Gw::Property::ScheduleHelpConfig < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: "schedules", type_name: "help_link" }
  end

  def default_options
    Array.new(2, [''])
  end

  def help_links
    options_value.flatten
  end
end
