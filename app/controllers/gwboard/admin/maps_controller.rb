class Gwboard::Admin::MapsController < ApplicationController
  include System::Controller::Scaffold

  def initialize_scaffold
    self.class.layout 'admin/base'
  end

  def index
    item = Gwboard::Maps.new
    item.and :system_name, params[:system]
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:parent_id]
    item.and :field_name, params[:field_id]
    @items = item.find(:all)
    _index @item
  end


  def show

  end

  def edit
    item = Gwboard::Maps.new
    item.and :system_name, params[:system]
    item.and :title_id, params[:title_id]
    item.and :parent_id, params[:parent_id]
    item.and :field_name, params[:field_id]
    @item = Gwboard::Maps.find(params[:id])
    return http_error(404) unless @item
  end

  def new
    @item = Gwboard::Maps.new({
    })

  end

  def create
    @item = Gwboard::Maps.new(params[:item])
    @item.system_name = params[:system]
    @item.title_id = params[:title_id]
    @item.parent_id = params[:parent_id]
    @item.field_name =  params[:field_id]
    _create(@item, :success_redirect_uri => gwboard_maps_path(@item.parent_id) + "?system=#{@item.system_name}&title_id=#{@item.title_id}&field_id=#{@item.field_name}")
  end

  def update
    @item = Gwboard::Maps.find(params[:id])
    @item.attributes = params[:item]
    @item.system_name = params[:system]
    @item.title_id = params[:title_id]
    @item.parent_id = params[:parent_id]
    @item.field_name =  params[:field_id]
    _update(@item, :success_redirect_uri => gwboard_maps_path(@item.parent_id) + "?system=#{@item.system_name}&title_id=#{@item.title_id}&field_id=#{@item.field_name}")
  end

  def destroy
    @item = Gwboard::Maps.find_by_id(params[:id])
    str_redirect = gwboard_maps_path(@item.parent_id) + "?system=#{@item.system_name}&title_id=#{@item.title_id}&field_id=#{@item.field_name}"
    @item.destroy
    _destroy(@item, :success_redirect_uri => str_redirect)
  end

end
