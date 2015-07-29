# -*- encoding: utf-8 -*-
class Gwbbs::Admin::CategoriesController < Gw::Controller::Admin::Base


  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @title = Gwbbs::Control.find_by_id(params[:title_id])
    Page.title = "掲示板"
    return error_gwbbs_no_title unless @title
    @css = ["/_common/themes/gw/css/bbs.css"]
    begin
      get_category_parent
    rescue
      return error_gwbbs_no_database
    end
  end


  def get_category_parent
    item = gwbbs_db_alias(Gwbbs::Category)
    if params[:parent_id].blank? or params[:parent_id] == '0'
      @parent = item.new({:id => 0, :level_no => 0})
    else
      @parent = item.new.find(params[:parent_id])
    end
    Gwbbs::Category.remove_connection
  end


  #
  def index
    item = gwbbs_db_alias(Gwbbs::Category)
    item = item.new

    if @parent.id.blank?
      item.level_no = 1
    else
      item.parent_id = @parent.id
    end

    item.and  :title_id, params[:title_id]
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    Gwbbs::Category.remove_connection
    _index @items
  end

  def show
    item = gwbbs_db_alias(Gwbbs::Category)
    @item = item.new.find(params[:id])
    return error_auth unless @item
    Gwbbs::Category.remove_connection
    _show @item
  end

  def new
    title_id = params[:title_id]
    item = gwbbs_db_alias(Gwbbs::Category)
    @item = item.new({
      :state      => 'public',
      :parent_id  => @parent.id,
      :title_id  => title_id,
      :sort_no    => 1,
    })
    Gwbbs::Category.remove_connection
  end

  def create
    item = gwbbs_db_alias(Gwbbs::Category)
    @item = item.new(params[:item])
    @item.state = 'public'
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    _create @item, :success_redirect_uri => gwbbs_categories_path({:title_id=>params[:title_id],:parent_id=>params[:parent_id]})
  end

  def update
    item = gwbbs_db_alias(Gwbbs::Category)
    @item = item.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state = 'public'
    _update @item, :success_redirect_uri => gwbbs_categories_path({:title_id=>params[:title_id],:parent_id=>params[:parent_id]})
  end

  def destroy
    item = gwbbs_db_alias(Gwbbs::Category)
    @item = item.new.find(params[:id])
    unless @item.is_deletable?
      flash[:notice]="指定した分類に記事が登録されているため、削除できませんでした。"
      return redirect_to gwbbs_categories_path({:title_id=>params[:title_id],:parent_id=>params[:parent_id]})
    end
    _destroy @item, :success_redirect_uri => gwbbs_categories_path({:title_id=>params[:title_id],:parent_id=>params[:parent_id]})
  end

  def item_to_xml(item, options = {})
    options[:include] = [:status]
    xml = ''; xml << item.to_xml(options) do |n|
      n << item.creator.to_xml(:root => 'creator', :skip_instruct => true, :include => [:user, :group]) if item.creator
    end
    return xml
  end

end