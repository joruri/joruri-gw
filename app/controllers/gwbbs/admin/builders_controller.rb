class Gwbbs::Admin::BuildersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    @title = Gwbbs::Control.where(create_section: Core.user_group.code).first
  end

  def create
    if group = System::Group.select(:id, :code, :name).where(id: params[:board_group]).first
      title = create_bbs_board(group)
      create_default_category(title) if title
    end

    redirect_to '/gwbbs'
  end

  private

  def create_bbs_board(group)
    Gwbbs::Control.create(
      :state => 'public',
      :title => "#{group.name}掲示板" ,
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
      :admingrps_json => %Q{[["#{group.code}", "#{group.id}", "#{group.name}"]]},
      :adms_json => "[]",
      :editors_json => %Q{[["#{group.code}", "#{group.id}", "#{group.name}"]]},
      :sueditors_json => "[]",
      :readers_json => %Q{[["#{group.code}", "#{group.id}", "#{group.name}"]]},
      :sureaders_json => "[]",
      :limit_date => 'none',  #期限切れ削除機能は利用しない
      :docslast_updated_at =>  Time.now
    )
  end

  def create_default_category(title)
    create_category(title, 1, 'お知らせ')
    2.upto(8) do |i|
      create_category(title, i, params["cat0#{i}"]) if params["cat0#{i}"].present?
    end
  end

  def create_category(title, i, name)
    title.categories.create(
      state: 'public',
      sort_no: i * 10,
      name: name,
      level_no: 1
    )
  end
end
