class System::Admin::Api::DcnController < ActionController::Base
  protect_from_forgery :except => [:create_data, :delete_data]
  layout false

  def approval
    dump ['api_dcn_approval_login_common', Time.now.strftime('%Y-%m-%d %H:%M:%S'), request.parameters['url']]

    ret = Gw::Tool::Dcn.approval_api(params)

    dump ['api_dcn_approval_login_common_ret', Time.now.strftime('%Y-%m-%d %H:%M:%S'), ret]

    respond_to do |format|
      format.html { render :text => nil, :layout => false, :status => 200 }
      format.xml { render :text => nil, :layout => false, :status => 200 }
    end
  end
end
