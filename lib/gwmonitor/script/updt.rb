# -*- encoding: utf-8 -*-
class Gwmonitor::Script::Updt

  def self.field_update
    dump "#{self}, 回答システム件数更新 (処理開始)"
    model = Gwmonitor::Control.new
    model.and :state , 'public'
    items = model.find(:all)
    for item in items
      item.commission_count_update
    end

    dump "#{self}, 回答システム件数更新 (処理終了)"

  end
end
