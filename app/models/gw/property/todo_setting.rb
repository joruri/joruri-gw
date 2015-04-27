class Gw::Property::TodoSetting < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "todo", type_name: "json" }
  end

  def default_options
    { todos: {
        finish_todos_display: '0',
        unfinish_todos_display_start: '4',
        unfinish_todos_display_end: '4',
        todos_display_schedule: '1'
      } }
  end

  def display_options
    [['表示しない','0'],['当日のみ表示する','1'],['前日以降を表示する','2'],
    ['２日前以降を表示する','3'],['３日前以降を表示する','4'], ['４日前以降を表示する','5'],
    ['５日前以降を表示する','6']]
  end

  def display_start_options
    [['表示しない','0'],['当日から','1'],['前日から','2'],['２日前から','3'],
    ['３日前から','4'],['４日前から','5'],['５日前から','6']]
  end

  def display_end_options
    [['表示しない','0'],['当日までを表示する','1'],['翌日までを表示する','2'],['２日先までを表示する','3'],
    ['３日先までを表示する','4'],['４日先までを表示する','5'],['５日先までを表示する','6'],['６日先までを表示する','7'],['７日先までを表示する','8']]
  end

  def display_schedule_options
    [['表示しない','0'],['表示する','1']]
  end

  def todos
    options_value['todos'] || {}
  end

  def finish_todos_display
    todos['finish_todos_display']
  end

  def unfinish_todos_display_start
    todos['unfinish_todos_display_start']
  end 

  def unfinish_todos_display_end
    todos['unfinish_todos_display_end']
  end

  def todos_display_schedule 
    todos['todos_display_schedule']
  end

  def todos_display_schedule=(value) 
    self.options_value = options_value.deep_merge(todos: { todos_display_schedule: value.to_s })
  end

  def self.todos_display?
    self.where(uid: Core.user.id).first_or_new.todos_display_schedule == '1'
  end
end
