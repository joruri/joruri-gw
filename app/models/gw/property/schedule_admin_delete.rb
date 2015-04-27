class Gw::Property::ScheduleAdminDelete < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: "schedule", type_name: "json" }
  end

  def default_options
    { schedules: { schedules_admin_delete: '4', month_view_leftest_weekday: '1', view_place_display: '0' } }
  end

  def schedules
    options_value['schedules'] || {}
  end

  def schedules_admin_delete
    schedules['schedules_admin_delete']
  end

  def delete_options
    I18n.a('enum.gw/property/schedule_admin_delete.delete_options')
  end
end
