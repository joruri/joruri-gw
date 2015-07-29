class Gwcircular::Admin::Menus::CommissionsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    params[:limit] = @title.default_limit unless @title.default_limit.blank?

    @parent = Gwcircular::Doc.find_by_id(params[:parent_id])
    return http_error(404) unless @parent
    return http_error(404) unless @parent.doc_type == 0
  end

  def index
    get_role_index
    @is_readable = false unless @parent.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_readable
    commission_index
    Page.title = @title.title
  end

  def commission_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :parent_id , @parent.id
    item.and :state , 'preparation' unless params[:cond].blank?
    item.and 'sql', "state != 'preparation'" if params[:cond].blank?
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def list
    if params[:ids] and params[:ids].size > 0
      for id in params[:ids]
        item = Gwcircular::Doc.find(id)
        item.state = 'preparation' if params[:cond].blank?
        item.state = 'draft' unless params[:cond].blank?
        item.category4_id = 0
        item.save
      end
    end
    s_redirect = "/gwcircular/#{params[:parent_id]}/commissions" if params[:redirect_url].blank?
    s_redirect = params[:redirect_url] unless params[:redirect_url].blank?
    s_redirect = "#{s_redirect}?cond=#{params[:cond]}" unless params[:cond].blank?
    redirect_to s_redirect
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
