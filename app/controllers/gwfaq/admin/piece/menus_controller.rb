# -*- encoding: utf-8 -*-
class Gwfaq::Admin::Piece::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwfaq::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwfaq::Controller::AdmsInclude

  def initialize_scaffold
    skip_layout
    @title = Gwfaq::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
  end

  def index
    menu_index
  end

  def menu_index
    admin_flags(@title.id)

    params[:state] = 'DATE' if params[:state].blank?

    @base_item = gwfaq_db_alias(Gwfaq::Doc)
    normal_index(false)
    @groups = Gwboard::Group.level3_all
    group_index
    get_categories
    category_index
    monthlies_index
    Gwfaq::Doc.remove_connection()
    Gwfaq::Category.remove_connection()
  end

  def group_index
    item = @base_item.new
    item.and :title_id, params[:title_id]
    item.and :state, 'public'
    @grp_items = item.find(:all , :select => "section_code, section_name, count(id) as cnt",:group => "section_code",:order => "section_code")
  end

  def get_categories
    item = gwfaq_db_alias(Gwfaq::Category)
    item = item.new
    item.and :level_no, 1
    item.and :title_id, params[:title_id]
    @categories1 = item.find(:all, :select => "id, name", :order =>'sort_no')
  end

  def category_index
    item = @base_item.new
    item.and :title_id, params[:title_id]
    item.and :state, 'public'
    @cats = item.find(:all , :select => "category1_id, count(id) as cnt",:group => "category1_id",:order => "category1_id")
  end

  def monthlies_index
    item = @base_item.new
    item.and :title_id, params[:title_id]
    item.and :state, 'public'
    @monthlies = item.find(:all , :select => "DATE_FORMAT(latest_updated_at,'%Y年%m月') AS month ,DATE_FORMAT(latest_updated_at,'%Y') AS yy,DATE_FORMAT(latest_updated_at,'%m') AS mm ,count(id) as cnt",:group => "DATE_FORMAT(latest_updated_at,'%Y年%m月')",:order => "DATE_FORMAT(latest_updated_at,'%Y年%m月') DESC")
  end


  def index_docs
    @loop = 10

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwboard_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    @items = item.find(:all)
    unless @items.blank?
      @current = params[:pp]
      if @current.blank?
        @start = 1
        @current = 1
      else
        @current = @current.to_i
        @start = @current - 4
      end

      @start = 1 if @start < 1
      @start = @items.length if @items.length < @start

      @current = 1 if @current < 1
      @current = @items.length if @items.length < @current

      loop = 10
      @end = @start + loop - 1
      @end = @items.length if @items.length < @end

      @loop = @loop - (@end - @start)
    end

    @base_item = gwfaq_db_alias(Gwfaq::Doc)
    @groups = Gwboard::Group.level3_all
    group_index

    get_categories
    category_index
    monthlies_index
  end
end