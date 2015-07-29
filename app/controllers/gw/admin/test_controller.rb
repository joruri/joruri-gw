#encoding:utf-8
class Gw::Admin::TestController < ApplicationController
  include System::Controller::Scaffold

  def index

  end

  def convert_hash
    require 'json_parser'
    s_to = ''
    s_from = nz(params['s_from'],'')
    if s_from != ''
      s_to = nz(params['s_to'],'')
      case nz(params['s_mode_id'],0).to_i
#    [1,"yaml => json"],
#    [2,"json => yaml"],
#    [3,"yaml => xml"],
#    [4,"xml => yaml"],
#    [5,"xml => json"],
#    [6,"json => xml"],
#    [7,"notesxml => csv"],
      when 0
        s_to = s_from
      when 1
        hx = YAML.load(s_from)
        s_to = hx.to_json
      when 2
        hx = ::JsonParser.new.parse(s_from)
        s_to = hx.to_yaml
      when 3
        hx = YAML.load(s_from)
        s_to = hx.to_xml
      when 4
        hx = Hash.from_xml(s_from)
        s_to = hx.to_yaml
      when 5
        hx = Hash.from_xml(s_from)
        s_to = hx.to_json
      when 6
        hx = ::JsonParser.new.parse(s_from)
        s_to = hx.to_xml
      when 7
        hx = Gw::Script::Tool.from_notes_xml(s_from)
        s_to = Gw::Script::Tool.to_csv2(hx)
      when 8
        hx = Gw::Script::Tool.from_ldap_xml(s_from)
        s_to = Gw::Script::Tool.to_csv(hx)
      when 9
        hx = eval(s_from)
        s_to = hx.to_json
      when 10
        hx = eval(s_from)
        s_to = hx.to_yaml
      when 11
        hx = eval(s_from)
        s_to = hx.to_xml
      when 13
        hx = ::JsonParser.new.parse(s_from)
        s_to = PP.pp(hx,'')
      when 14
        require '/usr/local/lib/ruby/gems/1.8/gems/atomutil-0.0.9/lib/atomutil.rb'
        feeds = Atom::Feed.new :stream => s_from
        hxa = []
        feeds.entries.each do |x|
          hxa << x.to_s
        end
        hx = hxa.join(',')
        s_to = PP.pp(hx,'')
      when 15
        pp ['convert_hash',Time.now.strftime('%Y-%m-%d %H:%M:%S'),s_from]
        require 'open-uri'
        begin
          request.parameters['url'] = s_from
          ret = Gw::Tool::Dcn.approval_api(request)
        rescue Exception => e
          pp e.message
          pp e.backtrace
          ret = {:status=>500,:xml=>nil}
        end
        s_to = PP.pp(ret.to_s,'')
      when 16
        ret = Gw::Tool::Reminder.checker_api(Site.user.id)
        s_to  = PP.pp(ret[:xml].to_s)
      end
    end
    params[:s_to] = s_to
  end

  def import_csv
    require 'yaml'
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    @titles = hash_raw.keys.sort
    params['s_to'] = Gw::Script::Tool.import_csv params['s_from'], params['s_title']
  end

  def download
    mode = nz(session[:senddownload][:mode], '')
    filename = nz(session[:senddownload][:filename], '')

    case mode
    when 'file'
      tmp_filename = session[:senddownload][:tmp_filename]
      raise IOError unless File.exists? tmp_filename
      stream = open(tmp_filename) {|f| f.read}
      FileUtils.rm tmp_filename
    when 'session'
      stream = nz(session[:senddownload][:stream], '')
    end
    session[:senddownload] = nil
    response.headers['Content-Disposition'] = %Q(attachment; filename="#{filename}")
    render :text => stream, :layout => 'empty'
  end

  def params_viewer
    param_s = PP.pp(params, '')
    render :text => param_s, :layout => 'empty'
  end


  def redirect_pref_pieces
    id = params[:id]
    raise Gw::SystemError, '呼び出しが不正です。' if !Gw.int?(id)
    id = id.to_i

    item = Gw::EditLinkPiece.find_by_id(id)
    
    raise Gw::SystemError, '呼び出しが不正です。' if item.blank?

    redirect_page = redirect_page_create(item.link_url, item.field_account, item.field_pass)

    render :text => redirect_page, :layout => 'empty'
  end

private

  def redirect_page_create(url, field_account, field_pass)

    redirect_page = <<-EOL
<html>
<head>
<meta http-equiv="Content-Language" content="ja">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Expires" content="-1">
<title>redirect</title>
<!--JavaScript-->
<script language="JavaScript">
<!--
function PostToAuth(){
  document.loginform.submit();
}
-->
</script>
</head>
<body onLoad="PostToAuth();">
<form name="loginform" action="#{url}" method="post" >
<input type="hidden" name="#{field_account}" value="#{Site.user.code}">
<input type="hidden" name="#{field_pass}" value="#{Site.user.password}">
</form>
</body>
</html>
EOL

    return redirect_page
  end

end
