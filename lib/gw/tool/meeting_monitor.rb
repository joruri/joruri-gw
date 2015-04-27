module Gw::Tool::MeetingMonitor
  require 'builder'
  def self.accesslog_save(ip_addr=nil)
    item = Gw::MeetingAccessLog.new
    item.ip_address = ip_addr
    item.save(:validate=>false)
  end

  def self.access_monitor_to_xml(state='off',ip_addr=nil,kind=1)
    xm = Builder::XmlMarkup.new :indent => 2
    xm.instruct!(:xml, :encoding => "UTF-8")   # <?xml version="1.0" encoding="UTF-8"?>
    item = Gw::MeetingMonitorSetting.where('conditions != "deleted" AND deleted_at IS NULL AND ip_address = ? AND monitor_type = ?',ip_addr, kind).order('updated_at desc').first
    if item.blank?
      item = Gw::MeetingMonitorSetting.new
      item.ip_address = ip_addr
      item.conditions = 'disabled'
      item.holiday_notice = 'off'
      item.weekday_notice = 'on'
      item.monitor_type = kind
      item.name = "Airシステム"
      item.state = 'off'
      item.save(:validate=>false)
    else
      if item.conditions=="enabled"
        if state=='on'
          item.state = 'on'
        else
          item.state = 'off'
        end
        if item.save(:validate=>false)
          result = "true"
        else
          result = "false"
        end
      else
        result = "false"
      end
    end
    xml = xm.xml_data {
      xm.entry do
        xm.result(result)
      end
      }
    return xml
  end

  def self.monitor_ips(type=nil, ip_addr = nil)
    xm = Builder::XmlMarkup.new :indent => 2
    xm.instruct!(:xml, :encoding => "UTF-8")   # <?xml version="1.0" encoding="UTF-8"?>
    #タイプごとのモニター、IPを出力する
    items = Gw::MeetingMonitorSetting.where("conditions = ? AND deleted_at IS NULL AND monitor_type = ? AND ip_address != ? ", "enabled", type, ip_addr)
    if items.blank?
      xml = xm.xml_data {
        xm.entry do
          xm.result("登録データがありません。")
        end
        }
    else
      xml = xm.xml_data{
        items.each do |m|
          xm.entry do
            xm.ipaddr(m.ip_address)
          end
        end
      }
    end
    return xml
  end
end