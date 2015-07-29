# encoding: utf-8
module Gw::Controller::Schedule

  def self.convert_ical(schedules, options={})

    if !options[:end_day].blank?
      end_day = Time.parse(options[:end_day])
    end

    require 'icalendar'
    categories = Gw::NameValue.get_cache('yaml', nil, "gw_schedules_title_categories")
    cal = Icalendar::Calendar.new

    cal.timezone do
      tzid 'Asia/Tokyo'
      standard do
        tzoffsetfrom '+0900'
        tzoffsetto   '+0900'
        dtstart      '19700101T000000'
        tzname       'JST'
      end
    end
    schedules.each {|schedule|
      repeat_flag = 0
      parent_flag = 0
      if !schedule.schedule_repeat_id.blank?
        repeat_flag = 1
        childs = schedule.repeat.schedules.sort{|a, b|a.st_at<=>b.st_at}
        parent = childs.shift
        if parent.id == schedule.id
          parent_flag = 1
        end
      end
      sdt = schedule[:st_at]
      sdt = DateTime.new(sdt.year, sdt.month, sdt.day, sdt.hour, sdt.min, 0, Rational(+9,24))
      edt = schedule[:ed_at]
      edt = DateTime.new(edt.year, edt.month, edt.day, edt.hour, edt.min, 0, Rational(+9,24))
      cdt = schedule[:created_at]
      cdt = DateTime.new(cdt.year, cdt.month, cdt.day, cdt.hour, cdt.min, 0, Rational(+9,24))
      cal.event do
        if repeat_flag == 1
          if parent_flag == 1
            if schedule.repeat.class_id == 1 #毎日
              uid 'schedule_' + schedule.id.to_s + '@' + ENV['HOSTNAME'].to_s
              r_sdt = schedule.repeat.st_date_at
              r_edt = schedule.repeat.ed_date_at
              if !end_day.blank? && r_edt > end_day
                r_edt = end_day
              end
              u_dt = DateTime.new(r_edt.year, r_edt.month, r_edt.day, 23, 59, 59, Rational(+9,24)).new_offset(Rational(0,24))
              add_rrule "FREQ=DAILY;UNTIL=" + u_dt.strftime("%Y%m%dT%H%M%SZ")

            elsif schedule.repeat.class_id == 2 #毎日（土日除く
              uid 'schedule_' + schedule.id.to_s + '@' + ENV['HOSTNAME'].to_s
              r_sdt = schedule.repeat.st_date_at
              r_edt = schedule.repeat.ed_date_at
              if !end_day.blank? && r_edt > end_day
                r_edt = end_day
              end
              u_dt = DateTime.new(r_edt.year, r_edt.month, r_edt.day, 23, 59, 59, Rational(+9,24)).new_offset(Rational(0,24))
              add_rrule "FREQ=WEEKLY;UNTIL=" + u_dt.strftime("%Y%m%dT%H%M%SZ") + ";BYDAY=MO,TU,WE,TH,FR"

            elsif schedule.repeat.class_id == 3 #毎週（曜日選択
              uid 'schedule_' + schedule.id.to_s + '@' + ENV['HOSTNAME'].to_s
              r_sdt = schedule.repeat.st_date_at
              r_edt = schedule.repeat.ed_date_at
              if !end_day.blank? && r_edt > end_day
                r_edt = end_day
              end
              u_dt = DateTime.new(r_edt.year, r_edt.month, r_edt.day, 23, 59, 59, Rational(+9,24)).new_offset(Rational(0,24))
              wstr = ''
              wary = ['SU','MO','TU','WE','TH','FR','SA']
              schedule.repeat.weekday_ids.split(":").each{|x|
                wstr += ( wstr.blank? ? wary[x.to_i] : ',' + wary[x.to_i] )
              }
              add_rrule "FREQ=WEEKLY;UNTIL=" + u_dt.strftime("%Y%m%dT%H%M%SZ") + ";BYDAY=" + wstr

            end
          else
            uid 'schedule_' + parent.id.to_s + '@' + ENV['HOSTNAME'].to_s
            if schedule.allday == 1 || schedule.allday == 2
              recurrence_id Date.new(sdt.year, sdt.month, sdt.day), {'VALUES' => 'DATE'}
            else
              recurrence_id sdt, {'TZID' => 'Asia/Tokyo'}
            end
          end
        else
          uid 'schedule_' + schedule.id.to_s + '@' + ENV['HOSTNAME'].to_s
        end

        if schedule.allday == 1 || schedule.allday == 2
          sdt = schedule.ed_at
          sdt = Date.new(sdt.year, sdt.month, sdt.day)
          edt = schedule.ed_at
          edt = Date.new(edt.year, edt.month, edt.day) + 1
          dtstart sdt, {'VALUES' => 'DATE'}
          dtend   edt, {'VALUES' => 'DATE'}
        else
          dtstart sdt, {'TZID' => 'Asia/Tokyo'}
          dtend   edt, {'TZID' => 'Asia/Tokyo'}
        end
        add_categories categories[schedule.title_category_id] if !schedule.title_category_id.blank?
        summary schedule[:title]
        description schedule[:memo]
        location schedule[:place]
        dtstamp cdt, {'TZID' => 'Asia/Tokyo'}

      end
    }
    ical = cal.to_ical
    return ical
  end
end
