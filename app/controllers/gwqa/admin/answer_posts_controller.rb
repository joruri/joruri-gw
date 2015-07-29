# -*- encoding: utf-8 -*-
class Gwqa::Admin::AnswerPostsController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"


  def initialize_scaffold
    alter_table_name_gwqa
    Page.title = "質問管理"
  end

  def is_user_compare(item)
    user_compare = false
    unless item.creator.nil?
      user_compare = true if Site.user.code == item.creater_id
    end
    return user_compare
  end

  def show
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless is_authorized(@title)

    @parent = @qa_doc_table.find_by_id(params[:parent_id])
    return error_gwbbs_no_title unless is_authorized(@parent)

    item = @qa_doc_table.new
    item.creator
    item.readable
    @item = item.find(params[:id])
    if is_user_compare(@item)
        @permit_user = true
        flash[:notice] = ""
    else
      @permit_user = false
      flash[:notice] = "記事作成者以外の編集・削除処理は出来ません。"
    end
  end

  def new
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless @title
    return error_gwbbs_no_title unless @title.state == 'public'

    @parent = @qa_doc_table.find_by_id(params[:parent_id])
    return error_gwbbs_no_title unless @parent
    return error_gwbbs_no_title unless @parent.state == 'public'

    @item = @qa_doc_table.new({
      :state => 'public' ,
      :title_id   => @title.id ,
      :parent_id => @parent.id ,
      :doc_type => 1 ,
      :published_at  => Core.now ,
      :latest_updated_at => Core.now ,
      :content_id => Site.current_node.content_id
    })

  end

  def create
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless @title
    return error_gwbbs_no_title unless @title.state == 'public'

    @parent = @qa_doc_table.find_by_id(params[:parent_id])
    return error_gwbbs_no_title unless @parent
    return error_gwbbs_no_title unless @parent.state == 'public'

    @item = @qa_doc_table.new(params[:item])
    p @item.state
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.doc_type = 1
    @item.published_at  = Core.now
    @item.latest_updated_at = Core.now
    @item.content_id = Site.current_node.content_id

    @item.createdate = Core.now
    @item.creater_id = Site.user.code unless Site.user.code.blank?
    @item.creater = Site.user.name unless Site.user.name.blank?
    @item.createrdivision = Site.user_group.name unless Site.user_group.name.blank?

    _create_after_set_location @item
  end

  def edit
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless @title
    return error_gwbbs_no_title unless @title.state == 'public'

    @parent = @qa_doc_table.find_by_id(params[:parent_id])
    return error_gwbbs_no_title unless @parent
    return error_gwbbs_no_title unless @parent.state == 'public'

    item = @qa_doc_table.new
    @item = item.find(params[:id])
    unless is_user_compare(@item)
        redirect_to @item.gwqa_show_path
    end
  end

  def update
    @title = @qa_control_table.find_by_id(params[:title_id])

    return error_gwbbs_no_title unless @title
    return error_gwbbs_no_title unless @title.state == 'public'

    @parent = @qa_doc_table.find_by_id(params[:parent_id])

    return error_gwbbs_no_title unless @parent
    return error_gwbbs_no_title unless @parent.state == 'public'

    @item = @qa_doc_table.find(params[:id])
    @item.attributes = params[:item]
    @item.latest_updated_at = Core.now

    @item.editdate = Core.now
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?

    if @item.state == 'recognized'
      location = @item.gwqa_preview_path
    else
      location = @item.gwqa_preview_index_path
    end

    _update_plus_location @item, location
  end

  def destroy
    @item = @qa_doc_table.new.find(params[:id])
    _destroy_plus_location @item, @item.gwqa_doc_index_path
  end
end