# -*- encoding: utf-8 -*-
class Gwcircular::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize
  layout "admin/template/gwcircular"


  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = "回覧板"
    @css = ["/_common/themes/gw/css/circular.css"]

    s_state = ''
    s_state = "?state=#{params[:state]}" unless params[:state].blank?
    return redirect_to("#{Site.current_node.public_uri}#{s_state}") if params[:reset]
    
    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank?
      item = Gwcircular::Doc.find(params[:id])
      unless item.blank?
        if item.doc_type == 0
          params[:cond] = 'owner'
        end
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end
      end
    end
  end

  def index
    redirect_to "#{@title.item_home_path}"
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(@title.id)

    item = Gwcircular::Doc.new
    item.and :id, params[:id]
    item.and :state ,'!=', 'preparation'
    @item = item.find(:first)
    return http_error(404) if @item.blank?

    get_role_show(@item)  #admin, readable, editable
    @is_readable = false unless @item.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_readable

    if @item.state == 'unread'
      @item.state = 'already'
      @item.published_at = Time.now
      @item.latest_updated_at = Time.now
      update_creater_editor_circular
      @item._commission_count = true
      @item.save
      params[:cond] = 'already'
    end unless @item.confirmation == 1

    @parent = Gwcircular::Doc.find_by_id(@item.parent_id)
    return http_error(404) unless @parent

    commission_index
  end

  def commission_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :state ,'!=', 'preparation'
    item.and :parent_id, @item.parent_id
    item.and :target_user_code,'!=', Site.user.code
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @commissions = item.find(:all)
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = Gwcircular::Doc.new
    item.and :id, params[:id]
    item.and :state ,'!=', 'preparation'
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_edit(@item)

    @is_readable = false unless @item.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_editable
    @parent = Gwcircular::Doc.find_by_id(@item.parent_id)
    return http_error(404) unless @parent
    Page.title = @title.title
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find_by_id(params[:id])
    return http_error(404) unless @item

    @parent = Gwcircular::Doc.find_by_id(@item.parent_id)

    @is_writable = false unless @item.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_writable

    @before_state = @item.state
    @item.attributes = params[:item]

    if @before_state == 'unread'
      @item.published_at = Time.now
    end if @item.published_at.blank?

    @item.latest_updated_at = Time.now
    update_creater_editor_circular
    @item._commission_count = true
    location = "#{@item.show_path}?cond=#{params[:cond]}"
 
    _update(@item, :success_redirect_uri=>location)
  end

  def already_update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find_by_id(params[:id])
    return http_error(404) unless @item

    @is_writable = false unless @item.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_writable
    @item.state = 'already'
    @item.latest_updated_at = Time.now
    @item.published_at = Time.now
    update_creater_editor_circular
    @item._commission_count = true
    @item.save
    location = "#{@item.show_path}?cond=already"
    redirect_to location
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
