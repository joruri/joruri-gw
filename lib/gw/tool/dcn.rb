class Gw::Tool::Dcn

  def self.approval_api(params)
dump ["Gw::Tool::Dcn.approval_api", Time.now.strftime('%Y-%m-%d %H:%M:%S'), params]
    # 決裁REST連携で、XMLを取得してリマインダーに表示するデータを作成する
    #----------------------------------------------------------------
    u_code  = params[:ucode]
    #----------------------------------------------------------------
    # エンドポイントのユーザーをチェック
    ug = System::UsersGroup.where(:end_at => nil, :user_code => u_code).order(:start_at => :desc).first
    if ug.blank?
      # 存在しなければ終了
      dump "illegal request u_code = #{u_code}"
      return error_state
    end
    #----------------------------------------------------------------
    ret  = Gw::Tool::Dcn.approval_uri(u_code)
    # 接続先uriが取得できないとき
    if ret[:state]!=200
      return error_state
    end
    #----------------------------------------------------------------
    # 承認依頼のXMLを取得
    ret = Gw::Tool::Dcn.approval_get_xml(ret[:uri])
    # xmlが取得できないとき
    if ret[:state]!=200
      return ret
    end
    #----------------------------------------------------------------
    # 文字コードをUTF-8に変換　（入力は自動判別）
    f =  NKF::nkf('-w', ret[:xml])
    #----------------------------------------------------------------
    # XMLから表示用のデータをテーブルに登録
    ret = Gw::Tool::Dcn.approval_xml_parse(f, u_code)
dump ['Gw::Tool::Dcn.approval_api', Time.now.strftime('%Y-%m-%d %H:%M:%S'), ret[:state]]
    return {:state => ret[:state], :xml => nil}
  end

  def self.approval_uri(u_code)
    setting = Gw::Property::DcnApprovalLink.first_or_new
    #----------------------------------------------------------------
    # 接続先未登録は終わり
    if setting.options_value.blank?
      return error_state
    end
    #----------------------------------------------------------------
    dcn_uri = setting.options_value
    if u_code.size == 7
      dcn_uri << "?deptno=#{u_code}"
    else
      if u_code.size < 7
      # for test
        case u_code.size
        when 6
          code = '0'+u_code
        when 5
          code = '00'+u_code
        when 4
          code = '000'+u_code
        when 3
          code = '0000'+u_code
        when 2
          code = '00000'+u_code
        when 1
          code = '000000'+u_code
        else
          return error_state
        end
        dcn_uri << "dcn_dcn_#{code}.xml"
      else
        return error_state
      end
    end
    return {:state => 200, :uri => dcn_uri}
  end

  def self.approval_get_xml(uri)
    # エンドポイントアクセスで起動して、リクエストを解析
    #----------------------------------------------------------------
    #決裁xml 取得
    require 'open-uri'
    xmls = ''
    status = nil
    begin
      open(uri) do |f|
        status = f.status[0].to_i
        f.each_line {|line| xmls += line}
      end
    rescue
      xmls = nil
    end
dump %Q(Gw::Tool::Dcn.approval_get_xml #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} state~#{status} xmls=#{xmls})
    if xmls.blank?
      return {:state => 404, :xml => nil}
    end
    return {:state => 200, :xml => xmls}
  end

  def self.approval_xml_parse(f,u_code)
dump ['Gw::Tool::Dcn.approval_xml_parse', Time.now.strftime('%Y-%m-%d %H:%M:%S'), 'parse']
    # 表示対象ユーザーを取得
    ug = System::UsersGroup.where(:end_at => nil, :user_code => u_code).order(:start_at => :desc).first
    if ug.blank?
      dump "illegal request u_code= #{u_code}"
      return error_state
    end
    #----------------------------------------------------------------
    # xml parse
    f.gsub!(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
    feed = Atom::Feed.new :stream => f

    if feed.blank?
      return error_state
    end

    ret = []
    Gw::DcnApproval.transaction do
      Gw::DcnApproval.where(:uid => ug.user_id).update_all(:state => 2)
      if feed.entries.blank?
        return {:state => 200, :purse => nil}
      end
      parse = feed.entries.sort{|a,b| b.id <=> a.id}
      ret = parse.map{|x|
        link_url = x.link.href.split('?')
        link_params = link_url[1].split('&')
        confirmdocno = ""
        routetype = ""
        deptno = ""
        link_params.each do |p|
          p0 = p.split('=')
          case p0[0]
          when 'confirmdocno'
            confirmdocno = p0[1]
          when 'routetype'
            routetype = p0[1]
          when 'deptno'
            deptno = p0[1]
          else
          end
        end
        {
          'date' => Gw::Tool::Dcn.format_datetime(x.updated),
          'id' => x.id,
          'title' => x.title,
          'link' => x.link.href,
          'confirmdocno' => confirmdocno ,
          'routetype' => routetype ,
          'deptno' => deptno ,
          'link_base' => link_url[0],
          'link_params' => link_url[1],
          'fr_user' => x.author.name,
          'contributor' => x.contributor.name
        }
      }
      ret.each do |r|
        # sso link data
        sso = Gw::DcnApproval.new
        sso.state       = 1
        sso.uid         = ug.user_id
        sso.u_code      = u_code
        sso.gid         = ug.group_id
        sso.g_code      = ug.group_code
        sso.class_id    = 3
        sso.title       = r['title']
        sso.st_at       = nil
        sso.ed_at       = r['date']
        sso.is_finished = 1
        sso.is_system   = 1
        sso.author      = r['fr_user']
        sso.save(:validate => false)
        # sso link url
        sso.options     = {
          :url          =>  r['link_base'],
          :confirmdocno =>  r['confirmdocno'],
          :routetype    =>  r['routetype'],
          :deptno       =>  r['deptno']
        }.to_json
        sso.body        = %Q(<a href="/_admin/gw/link_sso/#{sso.id}/redirect_to_dcn" target="_blank">[⇒#{r['contributor']}]　#{r['title']}　[#{r['fr_user']}]</a> )
        sso.save(:validate => false)
      end
    end

    return {:state => 200, :purse => ret}
  end

  def self.error_state
    {:state => 404, :xml => nil}
  end

private

  def self.format_datetime(d)
    # utcが前提で、local用に9時間加算
    format  = '%Y-%m-%d %H:%M:%S'
    ret_d   = ""
    case d.class.to_s
    when 'DateTime', 'Time'
      local_d = d + 9*60*60
      ret_d   = local_d.strftime(format)
    when 'String'
      local_d = DateTime.parse(d) + 9*60*60
      ret_d   = local_d.strftime(format)
    else
      raise TypeError, "unknown class type"
    end
    return ret_d
  end
end
