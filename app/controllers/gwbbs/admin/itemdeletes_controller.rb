# -*- encoding: utf-8 -*-
class Gwbbs::Admin::ItemdeletesController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwbbs::Controller::AdmsInclude
  include Gwboard::Controller::Authorize

  layout "admin/template/admin"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/bbs.css"]
    Page.title = "掲示板記事削除"
    
    check_gw_system_admin
    return authentication_error(403) unless @is_sysadm
  end

  def index
    
  end

  def new
    item = Gwbbs::Itemdelete.new
    item.and :content_id, 0
    item = item.find(:first)
    limit = ''
    limit = item.limit_date unless item.blank?

    @item = Gwbbs::Itemdelete.new({
      :content_id => 0 ,
      :admin_code => Core.user.code ,
      :limit_date => limit
    })
  end

  def create
    Gwbbs::Itemdelete.delete_all(["content_id = 0"])
    @item = Gwbbs::Itemdelete.new(params[:item])
    @item.content_id = 0
    @item.admin_code = Core.user.code
    _create @item
  end

  def target_record
    create_target_record
    redirect_to "#{admin_item_deletes_path}/direct/edit"
  end

  def edit
    item = Gwbbs::Itemdelete.new
    item.and :content_id, 2
    item.and :admin_code, Core.user.code
    item.order 'board_sort_no, title_id'
    item.page  params[:page], 10
    @items = item.find(:all)
  end

  def destroy
    @title = Gwbbs::Control.find_by_id(params[:id])
    unless @title.blank?
      @img_path = "public/_common/modules/#{@title.system_name}/"
      item = gwbbs_db_alias(Gwbbs::Doc)

      doc_item = item.new
      doc_item.and :state, 'preparation'
      doc_item.and :created_at, '<' , Date.yesterday.strftime("%Y-%m-%d") + ' 00:00:00'
      @items = doc_item.find(:all)
      for @item in @items
        destroy_comments
        destroy_atacched_files
        destroy_files
        @item.destroy
      end

      doc_item = item.new
      doc_item.and :state, '!=' ,'preparation'
      doc_item.and :expiry_date, '<' , Date.today.strftime("%Y-%m-%d") + ' 00:00:00'
      @items = doc_item.find(:all)
      for @item in @items
        destroy_comments
        destroy_atacched_files
        destroy_files
        @item.destroy
      end
      Gwbbs::Doc.remove_connection
      create_target_record
    end
    str_page = "?page=#{params[:page]}" unless params[:page].blank?
    redirect_to "#{admin_item_deletes_path}/direct/edit#{str_page}"
  end
  
protected
  
  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_comments
    item = gwbbs_db_alias(Gwbbs::Comment)
    item.destroy_all(sql_where)
    Gwbbs::Comment.remove_connection
  end

  def destroy_atacched_files
    item = gwbbs_db_alias(Gwbbs::File)
    item.destroy_all(sql_where)
    Gwbbs::File.remove_connection
  end

  def destroy_files
    item = gwbbs_db_alias(Gwbbs::DbFile)
    item.destroy_all(sql_where)
    Gwbbs::DbFile.remove_connection
  end

  def create_target_record
    Gwbbs::Itemdelete.delete_all(["content_id = 2 AND admin_code = '#{Core.user.code}'"])

    items = Gwbbs::Control.find(:all,:order=>'sort_no, id')
    for @title in items
      begin
        count_item = gwbbs_db_alias(Gwbbs::Doc)
        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` = 'public'"
        sql +=" AND '" + Time.now.strftime("%Y-%m-%d %H:%M:%S") + "' BETWEEN `able_date` AND `expiry_date` GROUP BY `title_id`;"
        public_count = count_item.count_by_sql(sql)

        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` != 'preparation' AND `expiry_date` < '" + Date.today.strftime("%Y-%m-%d") + " 00:00:00'"
        delete_count = count_item.count_by_sql(sql)

        Gwbbs::Itemdelete.create({
          :content_id => 2 ,
          :admin_code => Core.user.code ,
          :title_id => @title.id ,
          :board_title => @title.title ,
          :board_state => @title.state == 'public' ? '公開中' : '非公開' ,
          :board_view_hide => @title.view_hide ? 'する' : 'しない',
          :board_sort_no => @title.sort_no ,
          :public_doc_count => public_count ,
          :void_doc_count => delete_count ,
          :dbname => @title.dbname ,
          :board_limit_date => @title.limit_date ,
          :limit_date => 'direct'
        })
      rescue
      end
      Gwbbs::Doc.remove_connection
    end
  end

  def check_gw_system_admin
    @is_sysadm = true if System::Model::Role.get(1, Core.user.id ,'_admin', 'admin')
    @is_sysadm = true if System::Model::Role.get(2, Core.user_group.id ,'_admin', 'admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm
  end

end
