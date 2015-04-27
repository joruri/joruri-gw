class Gw::Property::ScheduleSetting < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "schedule", type_name: "json" }
  end

  def default_options
    { schedules: { month_view_leftest_weekday: '1', view_place_display: '0', view_portal_schedule_display: '1' } }
  end

  def schedules
    options_value['schedules'] || {}
  end

  def month_view_leftest_weekday
    schedules['month_view_leftest_weekday']
  end

  def month_view_leftest_weekday_options
    [['日曜日', '0'], ['月曜日', '1']]
  end

  def view_place_display
    schedules['view_place_display']
  end

  def view_place_display_options
    [['表示しない', '0'],['表示する', '1']]
  end

  def view_portal_schedule_display
    schedules['view_portal_schedule_display']
  end

  def view_portal_schedule_display=(val)
    schedules['view_portal_schedule_display'] = val
    encode!
  end

  def view_portal_schedule_display_options
    [['表示しない', '0'],['表示する', '1']]
  end

  def display_portal_schedule?
    view_portal_schedule_display == '1'
  end
end
