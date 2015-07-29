class Gwfaq::Admin::Piece::AdmsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwfaq::Model::DbnameAlias
  include Gwfaq::Controller::AdmsInclude

  def initialize_scaffold
    skip_layout
    @title = Gwfaq::Control.find_by_id(params[:title_id])
    return error_gwbbs_no_title if @title.blank?
    Page.title = @title.title
  end


  def index
    case params[:state].to_s
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    when 'VOID'
      normal_index(false)
    else
      all_index
    end
    page_loop_set
  end



  def page_loop_set
    @loop = 28
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
  end
end