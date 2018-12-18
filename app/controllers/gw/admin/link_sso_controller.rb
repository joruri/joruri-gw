require 'net/http'
class Gw::Admin::LinkSsoController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout false

  def index
  end

  def redirect_tab
    item = Gw::EditTab.find_by(id: params[:id])
    raise '呼び出しが不正です。' unless item

    @params = {
      title: item.name,
      url: item.link_url,
      method: 'post',
      account_field: item.field_account,
      password_field: item.field_pass
    }
    render :redirect
  end

  def redirect_link_piece
    item = Gw::EditLinkPiece.find_by(id: params[:id])
    raise '呼び出しが不正です。' unless item

    if item.name == 'メール' || item.id == 64 || item.id == 65
      params[:to] = 'mail'
      return redirect_to_joruri
    end

    @params = {
      title: item.name,
      url: item.link_url,
      method: 'post',
      account_field: item.field_account,
      password_field: item.field_pass
    }
    render :redirect
  end

  def redirect_portal_adds
    item = Gw::PortalAdd.find_by(id: params[:id])
    raise '呼び出しが不正です。' unless item

    @params = {
      title: item.title,
      url: item.link_url,
      method: 'post',
      account_field: item.field_account,
      password_field: item.field_pass
    }
    render :redirect
  end

  def redirect_to_external
    raise '呼び出しが不正です。' if params[:url].blank?

    @params = {
      url: params[:url],
      method: params[:method] || 'post',
      account_field: params[:user_field] || 'systemid',
      password_field: params[:pass_field] || 'systempasswd'
    }
    render :redirect
  end

  def redirect_to_joruri
    raise 'リダイレクト先の指定がありません。' unless params[:to]

    @product = System::Product.where(:product_type => params[:to]).first
    raise 'リダイレクト先の設定がありません。' unless @product

    @uri = request.mobile? ? @product.sso_uri_mobile : @product.sso_uri
    raise 'リダイレクト先の設定がありません。' unless @uri

    require 'net/http'
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true if @uri.scheme == 'https'
    request_query = {account: Core.user.code, password: Core.user.password}
    request_query[:mobile_password] = Core.user.mobile_password if request.mobile?
    http.start do |agent|
      response = agent.post(@uri.path, request_query.to_query)
      @token = response.body =~ /^OK/i ? response.body.gsub(/^OK /i, '') : nil
    end
    return redirect_to @uri.to_s unless @token

    if request.get?
      @uri.query = Hash.new.tap { |h|
        h[:account] = Core.user.code
        h[:token] = @token
        h[:path] = params[:path] if params[:path].present?
      }.to_query
      return redirect_to @uri.to_s
    end
  end

  def redirect_to_dcn
    sso = Gw::DcnApproval.find_by(id: params[:id])
    return redirect_to "/" if sso.blank?

    sso.options = sso.options.gsub('"','')
    options = sso.options.split(',')
    sso_options = []
    options.each do |o|
      if o =~ /\{/
          w_options = o.sub('{','').split(':')
          if w_options[0]=='url'
            sso_options << [w_options[0],w_options[1].to_s+':'+w_options[2].to_s]
          else
            sso_options << [w_options[0],w_options[1]]
          end
      else
        if o =~ /\}/
          w_options = o.sub('}','').split(':')
          if w_options[0]=='url'
            sso_options << [w_options[0],w_options[1].to_s+':'+w_options[2].to_s]
          else
            sso_options << [w_options[0],w_options[1]]
          end
        else
          w_options = o.split(':')
          if w_options[0]=='url'
            sso_options << [w_options[0],w_options[1].to_s+':'+w_options[2].to_s]
          else
            sso_options << [w_options[0],w_options[1]]
          end
        end
      end
    end

    options = sso_options.sort
    return redirect_to "/" unless options.assoc('url')
    @url = options.assoc('url')[1]
    return redirect_to "/" unless options.assoc('confirmdocno')
    @confirmdocno = options.assoc('confirmdocno')[1]
    return redirect_to "/" unless options.assoc('routetype')
    @routetype = options.assoc('routetype')[1]
    # 自動設定
    unless options.assoc('deptno')
      options <<['deptno' , "36000-#{Core.user.code}"]
    end
    @deptno  = options.assoc('deptno')[1]
    unless options.assoc('systemid')
      options << ['systemid' , "#{Core.user.code}"]
    end
    @systemid  = options.assoc('systemid')[1]
    unless options.assoc('systempasswd')
      pass  = Core.user.password
      options << ['systempasswd' , "#{pass}"]
    end
    @systempasswd  = options.assoc('systempasswd')[1]
  end

  # deprecated
  def redirect_pref_pieces
    redirect_link_piece
  end

  # deprecated
  def redirect_pref_soumu
    redirect_tab
  end
end
