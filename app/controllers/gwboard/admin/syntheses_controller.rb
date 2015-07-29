# encoding: utf-8
class Gwboard::Admin::SynthesesController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Authorize
  layout "admin/template/portal_1column"

  def initialize_scaffold
    item = Gwboard::Synthesetup.new
    item.and :content_id, 2
    item = item.find(:first)
    limit_date = ''
    limit_date = item.limit_date  unless item.blank?
    case limit_date
    when 'today'
      @date = Date.today.strftime('%Y-%m-%d')
    when 'yesterday'
      @date = Date.yesterday.strftime('%Y-%m-%d')
    when '3.days'
      @date = 3.days.ago.strftime('%Y-%m-%d')
    when '4.days'
      @date = 4.days.ago.strftime('%Y-%m-%d')
    else
      @date = Date.yesterday.strftime('%Y-%m-%d')
    end
    Page.title = "掲示板新着総合案内"
    @css = ["/_common/themes/gw/css/gwbbs_standard.css"]
    @date = @date + " 00:00:00"
    params[:limit] = 50
  end

  def index
    case params[:system].to_s
    when 'gwbbs'
      index_gwbbs
    when 'gwfaq'
      index_gwfaq
    when 'gwqa'
      index_gwqa
    when 'doclibrary'
      index_doclib
    when 'digitallibrary'
      index_digitallib
    else
      params[:system] = 'gwbbs'
      index_gwbbs
    end
  end

  def index_gwbbs
    item = Gwboard::Synthesis.new
    item.gwbbs_readable_syntheses(@date)
    item.page params[:page], params[:limit]
    @items = item.find(:all, 
      :select => 'gwboard_syntheses.*', 
      :order => 'gwboard_syntheses.latest_updated_at DESC')
  end

  def index_gwfaq
    item = Gwboard::Synthesis.new
    item.gwfaq_readable_syntheses(@date)
    item.page params[:page], params[:limit]
    @items = item.find(:all, 
      :select => 'gwboard_syntheses.*', 
      :order => 'gwboard_syntheses.latest_updated_at DESC')
  end

  def index_gwqa
    item = Gwboard::Synthesis.new
    item.gwqa_readable_syntheses(@date)
    item.page params[:page], params[:limit]
    @items = item.find(:all, 
      :select => 'gwboard_syntheses.*',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
  end

  def index_doclib
    item = Gwboard::Synthesis.new
    item.doclibrary_readable_syntheses(@date)
    item.page params[:page], params[:limit]
    @items = item.find(:all, 
      :select => 'gwboard_syntheses.*',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
  end

  def index_digitallib
    item = Gwboard::Synthesis.new
    item.digitallibrary_readable_syntheses(@date)
    item.page params[:page], params[:limit]
    @items = item.find(:all, 
      :select => 'gwboard_syntheses.*',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
  end

end