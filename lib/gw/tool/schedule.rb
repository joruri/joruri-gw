class Gw::Tool::Schedule
  require 'builder'
  def self.auth_false
    return false
  end

  def self.auth_nil
    return nil
  end

  def self.auth_true
    return true
  end


  def self.meetings_xml_output(date = nil)
    d = date
    st_date = d =~ /[0-9]{8}/ ? Date.strptime(d, '%Y%m%d') : Date.today

    # data getter
    model = Gw::Schedule.new
    cond_date = "'#{st_date.strftime('%Y-%m-%d 0:0:0')}' <= st_at and '#{st_date.strftime('%Y-%m-%d 23:59:59')}' >= st_at"
    cond = "guide_state = 2 and #{cond_date}"

    sches = model.find(:all, :order => 'allday DESC, st_at, ed_at, id',
      :conditions => cond
    )
    items = Gw::Schedule.schedule_show_support(sches)

    xm = Builder::XmlMarkup.new :indent => 2

    xm.instruct!(:xml, :encoding => "UTF-8")   # <?xml version="1.0" encoding="UTF-8"?>

    if items.length > 0
      xml = xm.xml_data {
        items.each do |item|
          xm.entry do
            xm.id(item.id)
            xm.kaigi(item.title)
            if item.allday == 1 || item.allday == 2
              xm.kaishi("―")
              xm.shuryo("")
            else
              xm.kaishi("#{item.st_at.strftime('%H:%M')}")
              if item.guide_ed_at == 1
                xm.shuryo("")
              else
                xm.shuryo("#{item.ed_at.strftime('%H:%M')}")
              end
            end
            xm.heya(item.guide_place)
          end
        end
      }
    else
      xml = xm.xml_data {
        xm.entry do
          xm.kaigi('本日ご案内する催事はございません')
        end
      }
    end

    # 文字参照のままで問題ないので、コメント化
    #xml = CGI.unescapeHTML(xml) # 文字参照に変更されてしまうので、変換しておく。
    return xml
  end

  def self.backgrounds_xml_output(host)
    item = Gw::MeetingGuideBackground.new
    cond  = "state != 'deleted' and published = 'opened'"
    order = "sort_no"
    items = item.find(:all,:order=>order,:conditions=>cond)

    xm = Builder::XmlMarkup.new :indent => 2
    xm.instruct!(:xml, :encoding => "UTF-8")   # <?xml version="1.0" encoding="UTF-8"?>

    if items.length > 0
      xml = xm.xml_data {
        items.each do |item|
          url = 'http://' + host + item.file_path.to_s
          xm.entry do
            xm.id(item.id.to_s)
            xm.path(url)
            xm.name(item.file_name)
            xm.label(item.caption)
            xm.style(item.background_color)
            xm.area(item.area)
            xm.sort_no(item.sort_no.to_s)
          end
        end
      }
    else
      xml = xm.xml_data {
        xm.entry do
          xm.kaigi('背景画像は登録されておりません。')
        end
      }
    end

    # 文字参照のままで問題ないので、コメント化
    #xml = CGI.unescapeHTML(xml) # 文字参照に変更されてしまうので、変換しておく。
    return xml
  end

  def self.notices_xml_output
    item = Gw::MeetingGuideNotice.new
    cond  = "state != 'deleted' and published = 'opened'"
    order = "sort_no"
    items = item.find(:all,:order=>order,:conditions=>cond)

    xm = Builder::XmlMarkup.new :indent => 2

    xm.instruct!(:xml, :encoding => "UTF-8")   # <?xml version="1.0" encoding="UTF-8"?>

    if items.length > 0
      xml = xm.xml_data {
        items.each do |item|
          xm.entry do
            xm.id(item.id.to_s)
            xm.body(item.title)
            xm.sort_no(item.sort_no.to_s)
          end
        end
      }
    else
      xml = xm.xml_data {
        xm.entry do
          xm.kaigi('お知らせは登録されておりません。')
        end
      }
    end

    # 文字参照のままで問題ないので、コメント化
    #xml = CGI.unescapeHTML(xml) # 文字参照に変更されてしまうので、変換しておく。
    return xml
  end


end
