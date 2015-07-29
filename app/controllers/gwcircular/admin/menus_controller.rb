# encoding:utf-8
class Gwcircular::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  layout "admin/template/gwcircular"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    Page.title = "回覧板"
    s_state = ''
    s_state = "?state=#{params[:state]}" unless params[:state].blank?
    return redirect_to("#{gwcircular_menu_path}#{s_state}") if params[:reset]
    @css = ["/_common/themes/gw/css/circular.css"]

    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank?

      item = Gwcircular::Doc.find_by_id(params[:id])
      unless item.blank?

        if item.doc_type == 0
          params[:cond] = 'owner'
        end unless params[:cond] == 'void'
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end unless params[:cond] == 'void'
      end
    end unless params[:cond] == 'void' unless params[:cond] == 'admin'
    params[:cond] = 'unread' if params[:cond].blank?
  end
  
  def jgw_circular_path
    return gwcircular_menus_path
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable
    case params[:cond]
    when 'unread'
      unread_index
    when 'already'
      already_read_index
    when 'owner'
      owner_index
    when 'void'
      owner_index
    when 'admin'
      return authentication_error(403) unless @is_admin
      admin_index
    else
      unread_index
    end
    Page.title = @title.title
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    item = Gwcircular::Doc.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item

    get_role_show(@item)  #admin, readable, editable

    @is_readable = false unless @item.target_user_code == Site.user.code unless @is_admin
    return authentication_error(403) unless @is_readable
    commission_index
  end

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 14 unless default_published

    @item = Gwcircular::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :doc_type => 0,
      :title => '',
      :body => '',
      :section_code => Site.user_group.code,
      :target_user_id => Site.user.id,
      :target_user_code => Site.user.code,
      :target_user_name => Site.user.name,
      :confirmation => 0,
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => default_published.days.since.strftime("%Y-%m-%d %H:00")
    })

    @item.state = 'draft'
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = Gwcircular::Doc.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    Page.title = @title.title
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find(params[:id])

    @before_state = @item.state
    @item.attributes = params[:item]

    @item.state = params[:item][:state]

    @item.latest_updated_at = Time.now

    if @item.target_user_code.blank?
      @item.target_user_code = Site.user.code
      @item.target_user_name = Site.user.name
    end if @is_admin

    unless @is_admin
      @item.target_user_code = Site.user.code
      @item.target_user_name = Site.user.name
    end
    update_creater_editor_circular
    @item._commission_count = true
    @item._commission_state = @before_state
    @item._commission_limit = @title.commission_limit
    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    if @item.state == 'draft'
      location = "#{jgw_circular_path}#{s_cond}"
    else
      location = "#{jgw_circular_path}/#{@item.id}/circular_publish#{s_cond}"
    end
    _update(@item, :success_redirect_uri=>location)
  end

  def destroy
    @item = Gwcircular::Doc.find(params[:id])
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    _destroy_plus_location(@item, "#{@title.menus_path}#{s_cond}" )
  end

  def unread_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :state , 'unread'
    item.and :target_user_code , Site.user.code
    item.and "sql", gwcircular_select_status(params)
    item.order 'expiry_date DESC'
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def already_read_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :state , 'already'
    item.and :target_user_code , Site.user.code
    item.and "sql", gwcircular_select_status(params)
    item.order 'expiry_date DESC'
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def owner_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 0
    item.and :state ,'!=', 'preparation'
    item.and :target_user_code, Site.user.code
    item.and "sql", gwcircular_select_status(params)
    item.order 'id DESC'
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def commission_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 1
    item.and :state ,'!=', 'preparation'
    item.and :parent_id, @item.id
    item.and "sql", gwcircular_select_status(params)
    item.search(params)
    item.order "state DESC, id"
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @commissions = item.find(:all)
  end

  def admin_index(no_paginate=nil)
    item = Gwcircular::Doc.new
    item.and :title_id , @title.id
    item.and :doc_type , 0
    item.and :state ,'!=', 'preparation'
    item.and "sql", gwcircular_select_status(params)
    item.order 'id DESC'
    item.search(params)
    item.page(params[:page], params[:limit]) if no_paginate.blank?
    @items = item.find(:all)
  end

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def clone
    item = Gwcircular::Doc.new
    item.and :id, params[:id]
    @item = item.find(:first)
    return http_error(404) unless @item
    get_role_edit(@item)
    clone_doc(@item)
  end

  def circular_publish
    item = Gwcircular::Doc.find_by_id(params[:id])
    return http_error(404) unless item
    item.publish_delivery_data(params[:id])
    item.state = 'public'
    item.save
    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    redirect_to "#{@title.menus_path}#{s_cond}"
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
