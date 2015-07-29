# -*- encoding: utf-8 -*-
class Gwcircular::Admin::CustomGroupsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message
  layout "admin/template/gwcircular"


  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    @css = ["/_common/themes/gw/css/circular.css"]
    params[:limit] = 200
    Page.title = "配信先個人設定"
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    item = Gwcircular::CustomGroup.new
    item.and :owner_uid , Site.user.id
    item.order 'sort_no, id'
    item.page params[:page], params[:limit]
    @items = item.find(:all)
  end

  def show

  end

  def new
    @item = Gwcircular::CustomGroup.new({
      :state => 'enabled',
      :sort_no => 10
    })
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::CustomGroup.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403)  unless @item.owner_uid == Site.user.id
  end

  def create
    get_role_index
    return authentication_error(403) unless @is_readable
    @item = Gwcircular::CustomGroup.new(params[:item])
    @item.owner_uid = Site.user.id
    _create @item
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::CustomGroup.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403)  unless @item.owner_uid == Site.user.id
    @item.attributes = params[:item]
    @item.owner_uid = Site.user.id
    _update(@item)
  end

  def destroy
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::CustomGroup.find(params[:id])
    return http_error(404) unless @item
    return authentication_error(403)  unless @item.owner_uid == Site.user.id
    _destroy(@item)
  end

  def sort_update
    item = Gwcircular::CustomGroup.new
    item.and :owner_uid , Site.user.id
    item.order 'sort_no, id'
    item.page params[:page], params[:limit]
    @items = item.find(:all)
    
    @item = Gwcircular::CustomGroup.new
    unless params[:item].blank?
      params[:item].each do |key,value|
        cgid = key.gsub(/sort_no_/, '').to_i
        if item = @items.find{|x| x.id == cgid}
          item.sort_no = value
          unless item.valid?
            item.errors.to_a.each{|msg| @item.errors.add(:base, msg)}
            break
          end
        end
      end
    end
    
    if @item.errors.size == 0
      @items.each{|item| item.save}
      flash_notice 'カスタムグループの並び順更新', true
      redirect_to '/gwcircular/custom_groups'
    else
      respond_to do |format|
        format.html { render :action => "index" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

end
