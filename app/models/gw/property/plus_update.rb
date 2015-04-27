class Gw::Property::PlusUpdate < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "plus_update" }
  end

  def default_options
    Array.new(1, ['4.days'])
  end

  def limit_options
    [['当日分のみ', 'today'],
      ['前日分から' , 'yesterday'],
      ['3日以内' , '3.days'],
      ['4日以内' , '4.days']]
  end

  def limit_value
    options_value[0].try(:first)
  end

  def limit_date_and_msg
    case limit_value
    when 'today'
      msg = '本日'
      date = Date.today.strftime('%Y-%m-%d 00:00:00')
    when 'yesterday'
      msg = '前日から'
      date = Date.yesterday.strftime('%Y-%m-%d 00:00:00')
    when '3.days'
      msg = '3日前から'
      date = 3.days.ago.strftime('%Y-%m-%d 00:00:00')
    when '4.days'
      msg = '4日前から'
      date = 4.days.ago.strftime('%Y-%m-%d 00:00:00')
    else
      msg = '本日'
      date = Date.yesterday.strftime('%Y-%m-%d 00:00:00')
    end
    return date, msg
  end
end
