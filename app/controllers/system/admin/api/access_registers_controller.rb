class System::Admin::Api::AccessRegistersController < ActionController::Base
  protect_from_forgery :except => [:exectives, :executives, :secretary, :access]
  #before_action :authenticate_user_password
  layout 'empty'


  def exectives
    dump ['api_pref_exectives',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    Gw::Tool::PrefExective.accesslog_save(request.remote_ip)
    xml = Gw::Tool::PrefExective.member_xml_output
    dump ['api_pref_exectives_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def executives
    dump ['api_pref_leaders',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if params[:kind] == "2"
      xml = Gw::Tool::PrefExective.leader_xml_output( 2 )
    else
      xml = Gw::Tool::PrefExective.leader_xml_output
    end
    dump ['api_pref_leaders_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def secretary
    dump ['api_pref_secretary',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if params[:kind] == "2"
      xml = Gw::Tool::PrefExective.secretary_xml_output( 2 )
    else
      xml = Gw::Tool::PrefExective.secretary_xml_output
    end
    dump ['api_pref_secretary_ret',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def access
    dump ['api_pref_access',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if params[:state] == "on"
      state = "on"
    else
      state = "off"
    end
    if params[:kind] == "2"
      xml = Gw::Tool::PrefExective.exective_access(state, params[:uid])
    else
      xml = Gw::Tool::PrefExective.assembly_access(state, params[:uid])
    end
    dump ['api_pref_access',Time.now.strftime('%Y-%m-%d %H:%M:%S'),xml]
    return render :xml => xml
  end

  def monitors
    dump ['api_pref_monitors',Time.now.strftime('%Y-%m-%d %H:%M:%S'),request.parameters['url']]
    if params[:type] == "1"
      type = 1
    else
      type = 2
    end
    ret = Gw::Tool::MeetingMonitor.monitor_ips(type,request.remote_ip)
    dump ['api_pref_monitors',Time.now.strftime('%Y-%m-%d %H:%M:%S'),ret]
    xml = ret
    return render :xml => xml
  end

end
