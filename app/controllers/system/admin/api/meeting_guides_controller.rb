class System::Admin::Api::MeetingGuidesController < ActionController::Base
  protect_from_forgery :except => [:meetings, :backgrounds, :notices, :accesses]
  #before_action :authenticate_user_password
  layout 'empty'

  def meetings
    dump ['api_schedule_kaigi_login_common',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if request.parameters['url'] =~ /[0-9]{8}$/
      date = request.parameters['url'][-8, 8]
    else
      date = nil
    end
    Gw::Tool::MeetingMonitor.accesslog_save(request.remote_ip)
    xml = Gw::Tool::Schedule.meetings_xml_output(date)
    dump ['api_schedule_kaigi_login_common_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end
  def backgrounds
    # 会議開催案内 背景画像
    dump ['api_schedule_back_login_common',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    uri = Util::Config.load(:core, :uri)
    uri = uri.gsub(/\/$/, '') if uri.present? && uri.end_with?("/")
    xml = Gw::Tool::Schedule.backgrounds_xml_output(uri)
    dump ['api_schedule_back_login_common_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def notices
    # 会議開催案内 お知らせ
    dump ['api_schedule_notice_login_common',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    xml = Gw::Tool::Schedule.notices_xml_output
    dump ['api_schedule_notice_login_common_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def accesses
    # 会議開催案内 Air監視状況の状態変更
    dump ['api_schedule_access_login_common',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if params[:monitor] == "on"
      monitor_state = 'on'
    else
      monitor_state = 'off'
    end
    if params[:kind] == "2"
      kind = 2
    else
      kind = 1
    end
    xml = Gw::Tool::MeetingMonitor.access_monitor_to_xml(monitor_state,request.remote_ip,kind)
    dump ['api_schedule_access_login_common_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end


end
