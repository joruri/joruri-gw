# -*- encoding: utf-8 -*-
class Gwqa::Admin::ContentsController < Gw::Controller::Admin::Base

  layout "admin/template/portal_1column"


  def initialize_scaffold
    Page.title = "質問管理"
  end

  def index
    if (params[:qsort] == nil) or (params[:qsort] == "") or (params[:qsort] == "1")
      @qsort = 1
      str_order = 'id'
      flash[:notice] = "【質問順】"
    else
      @qsort = 2
      str_order = 'latest_answer_updated_at DESC'
      flash[:notice] = "【最新から】"
    end

    item = Qa::Question.new
    item.page  params[:page], 5
    @items = item.find(:all,:order => str_order)

  end

  def show
    if (params[:asort] == nil) or (params[:asort] == "") or (params[:asort] == "1")
      @asort = 1
      str_order = 'id'
      flash[:notice] = "【回答順】"
    else
      @qsort = 2
      str_order = 'updated_at DESC'
      flash[:notice] = "【最新から】"
    end
    @item = Qa::Question.find(params[:id])
    return http_error(404) unless @item

    @answers = Qa::Answer.find(:all, :conditions =>{"question_id" => @item.id},:order=> str_order)

  end
end
