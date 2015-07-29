# -*- encoding: utf-8 -*-
class Gwbbs::Admin::Piece::MenusController < ApplicationController

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwbbs::Controller::AdmsInclude

  def initialize_scaffold
    @title = Gwbbs::Control.find_by_id(params[:title_id])
    return error_gwbbs_no_title if @title.blank?
  end

  #
  def index
    skip_layout
    admin_flags(@title.id)

    params[:state] = 'DATE' if params[:state].blank?

    @base_item = gwbbs_db_alias(Gwbbs::Doc)
    normal_index(false)
    flg_exception = false
    flg_exception = true if @title.form_name == 'form006'
    flg_exception = true if @title.form_name == 'form007'
    if flg_exception
      @groups  = @title.notes_field01
      group_index_form007
      get_categories
      category_index
      monthlies_index_form007 if @title.form_name == 'form006'
      monthlies_index if @title.form_name == 'form007'
    else
      @groups = Gwboard::Group.level3_all
      make_hash_group_doc_counts
      get_categories
      category_index
      monthlies_index
    end
    Gwbbs::Doc.remove_connection()
    Gwbbs::Category.remove_connection()
  end

  def make_hash_group_doc_counts
    str_sql  = 'SELECT section_code, count(id) as cnt'
    str_sql += ' FROM gwbbs_docs'
    str_sql += " WHERE state = 'public' AND title_id = #{@title.id}"
    str_sql += " AND '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    str_sql += ' GROUP BY section_code'
    item = gwbbs_db_alias(Gwbbs::Doc)
    @group_doc_counts = item.find_by_sql(str_sql).index_by(&:section_code)
  end

  def get_categories
    item = gwbbs_db_alias(Gwbbs::Category)
    item = item.new
    item.and :level_no, 1
    item.and :title_id, @title.id
    @categories1 = item.find(:all, :select => "id, name", :order =>'sort_no')
  end

  def category_index
    item = @base_item.new
    item.and :title_id, @title.id
    item.and :state, 'public'
    item.and "sql", "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    @cats = item.find(:all , :select => "category1_id, count(id) as cnt",:group => "category1_id",:order => "category1_id")
  end

  def monthlies_index
    item = @base_item.new
    item.and :title_id, @title.id
    item.and :state, 'public'
    item.and "sql", "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    @monthlies = item.find(:all , :select => "DATE_FORMAT(latest_updated_at,'%Y年%m月') AS month ,DATE_FORMAT(latest_updated_at,'%Y') AS yy,DATE_FORMAT(latest_updated_at,'%m') AS mm ,count(id) as cnt",:group => "DATE_FORMAT(latest_updated_at,'%Y年%m月')",:order => "DATE_FORMAT(latest_updated_at,'%Y年%m月') DESC")
  end

  def group_index_form007
    item = @base_item.new
    item.and :title_id, @title.id
    item.and :state, 'public'
    item.and "sql", "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    @grp_items = item.find(:all , :select => "inpfld_002, count(id) as cnt",:group => "inpfld_002",:order => "inpfld_002")
  end

  def monthlies_index_form007
    item = @base_item.new
    item.and :title_id, @title.id
    item.and :state, 'public'
    item.and "sql", "'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    @monthlies = item.find(:all , :select => "inpfld_006w,count(id) as cnt",:group => "inpfld_006w",:order => "DATE_FORMAT(inpfld_006d,'%Y年%m月') DESC")
  end

end