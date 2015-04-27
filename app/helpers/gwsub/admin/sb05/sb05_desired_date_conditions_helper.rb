module Gwsub::Admin::Sb05::Sb05DesiredDateConditionsHelper

  def sb05_diplay_weekno(item)
    str = []
    i = 0
    if item.w1 == true
      str[i] = "第１"
      i = i + 1
    end
    if item.w2 == true
      str[i] = "第２"
      i = i + 1
    end
    if item.w3 == true
      str[i] = "第３"
      i = i + 1
    end
    if item.w4 == true
      str[i] = "第４ "
      i = i + 1
    end
    if item.w5 == true
      str[i] = "第５"
      i = i + 1
    end
    ret = str.join("・")
    return ret
  end
  def sb05_diplay_weekday(item)
    str = []
    i = 0
    if item.d0 == true
      str[i] = "日曜日"
      i = i + 1
    end
    if item.d1 == true
      str[i] = "月曜日"
      i = i + 1
    end
    if item.d2 == true
      str[i] = "火曜日"
      i = i + 1
    end
    if item.d3 == true
      str[i] = "水曜日"
      i = i + 1
    end
    if item.d4 == true
      str[i] = "木曜日"
      i = i + 1
    end
    if item.d5 == true
      str[i] = "金曜日"
      i = i + 1
    end
    if item.d6 == true
      str[i] = "土曜日"
      i = i + 1
    end
    ret = str.join("・")
    return ret
  end
end
