module Gw::Model::Pes_year
  # 政策評価

  def self.remind(uid = nil)
    reminders = []

    item = Pes::Year.new
    item.reminder_cond
    yitem = item.find(:first)

    if yitem
      reminders << {
        :date_str => yitem.remind_ed_at.nil? ? '' : yitem.remind_ed_at.strftime("%m/%d %H:%M"),
        :cls => '政策評価',
        :title => yitem.show_remainder_title,
        :date_d => yitem.remind_ed_at
      }
    end

    reminders
  end
end
