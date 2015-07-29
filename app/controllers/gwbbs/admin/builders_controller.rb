# -*- encoding: utf-8 -*-
class Gwbbs::Admin::BuildersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias
  #include Gwfaq::Model::DbnameAlias

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    @title = Gwbbs::Control.find_by_create_section(Core.user_group.code)
  end

  def create
    unless params[:board_group].blank?
      create_bbs_board
      create_default_category unless @title.blank?
    end

    redirect_to '/gwbbs'
  end

  def create_bbs_board
    item = Gwboard::Group.find_by_id(params[:board_group],:select=>'id, code, name')
    return item if item.blank?

    @title = Gwbbs::Control.create({
      :state => 'public',
      :title => "#{item.name}掲示板" ,
      :published_at => Time.now,
      :recognize => 0,
      :importance => '1', #重要度使用
      :category => '1', #分類使用
      :left_index_use => '1', #左サイドメニュー
      :left_index_pattern => 0,
      :category1_name => '分類',
      :default_published => 3,
      :doc_body_size_capacity => 30, #記事本文総容量制限初期値30MB
      :doc_body_size_currently => 0, #記事本文現在の利用サイズ初期値0
      :upload_graphic_file_size_capacity => 10, #初期値10MB
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 30,  #初期値30MB
      :upload_document_file_size_capacity_unit => 'MB',
      :upload_graphic_file_size_max => 3, #初期値3MB
      :upload_document_file_size_max => 10, #初期値10MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :create_section => Core.user_group.code ,
      :sort_no => 0 ,
      :caption => "所属担当者による作成(#{Time.now.strftime("%Y-%m-%d %H:%M")})" ,
      :help_display => 1, #ヘルプを表示しない
      :upload_system => 3, #ファイル添付を全庁掲示板形式にする
      :view_hide => 1 ,
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :group_view  => false , #所属件数非表示
      :one_line_use => 1 ,  #１行コメント使用
      :notification => 1 ,  #記事更新時連絡機能を利用する
      :restrict_access => 0 ,
      :default_limit => '30',
      :form_name => 'form001' ,
      :createdate => Time.now.strftime("%Y-%m-%d %H:%M"),
      :creater_id => Core.user.code ,
      :creater => Core.user.name ,
      :createrdivision => Core.user_group.name ,
      :createrdivision_id => Core.user_group.code ,
      :editor_id => Core.user.code ,
      :editordivision_id => Core.user_group.code,
      :admingrps_json => %Q{[["#{item.code}", "#{item.id}", "#{item.name}"]]},
      :adms_json => "[]",
      :editors_json => %Q{[["#{item.code}", "#{item.id}", "#{item.name}"]]},
      :readers_json => %Q{[["#{item.code}", "#{item.id}", "#{item.name}"]]},
      :limit_date => 'none',  #期限切れ削除機能は利用しない
      :docslast_updated_at =>  Time.now
    })

  end

  def create_default_category
    @cat_item = gwbbs_db_alias(Gwbbs::Category)
    create_category(1, 'お知らせ')
    create_category(2, params[:cat02]) unless params[:cat02].blank?
    create_category(3, params[:cat03]) unless params[:cat03].blank?
    create_category(4, params[:cat04]) unless params[:cat04].blank?
    create_category(5, params[:cat05]) unless params[:cat05].blank?
    create_category(6, params[:cat06]) unless params[:cat06].blank?
    create_category(7, params[:cat07]) unless params[:cat07].blank?
    create_category(8, params[:cat08]) unless params[:cat08].blank?
    Gwbbs::Category.remove_connection
  end

  def create_category(i, name)
      item = @cat_item
      item.create({
        :state     => 'public',
        :title_id  => @title.id,
        :sort_no   => i * 10 ,
        :name   =>  name ,
        :level_no  => 1
      })
  end

  def gwbbs_output_files
    params[:id] = 48
    params[:system] = 'gwbbs'
    @title = Gwbbs::Control.find(params[:id])
    table = gwbbs_db_alias(Gwbbs::File)
    table = table.new
    items = table.find(:all)
    for item in items
      item.content_id = 2
      file = gwbbs_db_alias(Gwbbs::DbFile)
      db_file = file.find_by_id(item.db_file_id)
      unless db_file.blank?
        FileUtils.mkdir_p(item.f_path) unless FileTest.exist?(item.f_path)
        File.open(item.f_name, "wb") { |f|
          f.write db_file.data
        }
      end
      item.save

      update_doc_link(item)
    end
  end

  def update_doc_link(item)
    doc_item = gwbbs_db_alias(Gwbbs::Doc)
    doc_item = doc_item.find_by_id(item.parent_id)
    return if doc_item.blank?

    str = "<p>&nbsp;</p><p>&nbsp;</p>"
    str += "<a href=" + item.file_uri(params[:system]) + " class=\"" + item.icon_type + "\">" + %Q[#{item.filename} (#{item.eng_unit})] + "</a>"
    doc_item.body = doc_item.body + str
    doc_item.save
  end

end
