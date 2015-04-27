class Gw::Script::Schedule < System::Script::Base

  def self.delete
    run do
      settings = Gw::Property::ScheduleAdminDelete.first_or_new.schedules
      months = 6 * settings['schedules_admin_delete'].to_i
      return if months <= 0
  
      d1 = Date.today << months
  
      log "繰り返しスケジュール削除処理: #{I18n.l(d1)} 以前を削除" do
        del = 0
        Gw::ScheduleRepeat.where(["ed_date_at < ?", d1]).find_each do |repeat|
          if repeat.schedules.all? {|repeat_sche| repeat_sche.todo != 1} && repeat.delete
            del += 1
          end
        end
        log "#{del} deleted"
      end

      log "スケジュール削除処理: #{I18n.l(d1)} 以前を削除" do
        del = 0
        Gw::Schedule.where(todo: 0).where("ed_at < ?", d1).find_each do |sche|
          sche.schedule_props.each {|sp| sp._skip_destroy_actual = true }
          if sche.destroy
            del += 1
          end
        end
        log "#{del} deleted"
      end

      log "テーブル最適化" do
        Gw::Schedule.optimize_and_analyze_table
        Gw::ScheduleUser.optimize_and_analyze_table
        Gw::SchedulePublicRole.optimize_and_analyze_table
        Gw::ScheduleRepeat.optimize_and_analyze_table
        Gw::ScheduleProp.optimize_and_analyze_table
        Gw::ScheduleEvent.optimize_and_analyze_table
      end
    end
  end

  def self.todo_delete
    run do
      settings = Gw::Property::TodoAdminDelete.first_or_new.todos
      months = 6 * settings['todos_admin_delete'].to_i
      next if months <= 0

      d1 = Date.today << months

      log "ToDo削除処理: #{I18n.l(d1)} 以前を削除" do
        del = 0
        Gw::Schedule.where(todo: 1).where(["ed_at < ?", d1]).find_each do |sche|
          if sche.schedule_todo && sche.schedule_todo.is_finished.to_i == 1 && sche.schedule_todo.todo_ed_at_indefinite.to_i == 0
            if sche.destroy
              del += 1
            end
          end
        end
        log "#{del} deleted"
      end

      log "繰り返しToDo削除処理: #{I18n.l(d1)} 以前を削除" do
        del = 0
        Gw::ScheduleRepeat.where(["ed_date_at < ?", d1]).find_each do |repeat|
          if repeat.schedules.count == 0 && repeat.delete
            del += 1
          end
        end
        log "#{del} deleted"
      end

      log "テーブル最適化" do
        Gw::Schedule.optimize_and_analyze_table
        Gw::ScheduleUser.optimize_and_analyze_table
        Gw::SchedulePublicRole.optimize_and_analyze_table
        Gw::ScheduleTodo.optimize_and_analyze_table
        Gw::ScheduleRepeat.optimize_and_analyze_table
      end
    end
  end
end
