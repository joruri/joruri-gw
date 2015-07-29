# encoding: utf-8
class Gwboard::Admin::Piece::SynthesesController < ApplicationController
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Authorize
  layout 'base'
  
  def initialize_scaffold
    item = Gwboard::Synthesetup.new
    item.and :content_id, 0
    @select = item.find(:first)

    item = Gwboard::Synthesetup.new
    item.and :content_id, 2
    item = item.find(:first)
    limit_date = ''
    limit_date = item.limit_date  unless item.blank?
    case limit_date
    when 'today'
      @msg = '本日'
      @date = Date.today.strftime('%Y-%m-%d')
    when 'yesterday'
      @msg = '前日から'
      @date = Date.yesterday.strftime('%Y-%m-%d')
    when '3.days'
      @msg = '3日前から'
      @date = 3.days.ago.strftime('%Y-%m-%d')
    when '4.days'
      @msg = '4日前から'
      @date = 4.days.ago.strftime('%Y-%m-%d')
    else
      @msg = '本日'
      @date = Date.yesterday.strftime('%Y-%m-%d')
    end
    @date = @date + " 00:00:00"
  end
  
  def index
    index_gwbbs       if @select && @select.gwbbs_check
    index_gwfaq       if @select && @select.gwfaq_check
    index_gwqa        if @select && @select.gwqa_check
    index_doclib      if @select && @select.doclib_check
    index_digitallib  if @select && @select.digitallib_check

    @none_dsp = true
    @none_dsp = false unless @bbs_docs.blank?
    @none_dsp = false unless @faq_docs.blank?
    @none_dsp = false unless @qa_docs.blank?
    @none_dsp = false unless @doclib_docs.blank?
    @none_dsp = false unless @digitallib_docs.blank?
  end
  
  def index_gwbbs
    item = Gwboard::Synthesis.new
    item.gwbbs_readable_syntheses(@date)
    items = item.find(:all, 
      :select => 'latest_updated_at',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
    
    if items.length > 0
      @bbs_docs = "#{@msg} #{items.length}件の更新あり。最新記事は [ #{items[0].latest_updated_at.strftime('%Y年%m月%d日 %H時%M分').to_s} ] に更新。"
    end
  end
  
  def index_gwfaq
    item = Gwboard::Synthesis.new
    item.gwfaq_readable_syntheses(@date)
    items = item.find(:all, 
      :select => 'latest_updated_at',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
    
    if items.length > 0
      @faq_docs = "#{@msg} #{items.length}件の更新あり。最新記事は [ #{items[0].latest_updated_at.strftime('%Y年%m月%d日 %H時%M分').to_s} ] に更新。"
    end
  end
  
  def index_gwqa
    item = Gwboard::Synthesis.new
    item.gwqa_readable_syntheses(@date)
    items = item.find(:all, 
      :select => 'latest_updated_at',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
    
    if items.length > 0
      @qa_docs = "#{@msg} #{items.length}件の更新あり。最新記事は [ #{items[0].latest_updated_at.strftime('%Y年%m月%d日 %H時%M分').to_s} ] に更新。"
    end
  end
  
  def index_doclib
    item = Gwboard::Synthesis.new
    item.doclibrary_readable_syntheses(@date)
    items = item.find(:all, 
      :select => 'latest_updated_at', 
      :order => 'gwboard_syntheses.latest_updated_at DESC')
    
    if items.length > 0
      @doclib_docs = "#{@msg} #{items.length}件の更新あり。最新記事は [ #{items[0].latest_updated_at.strftime('%Y年%m月%d日 %H時%M分').to_s} ] に更新。"
    end
  end
  
  def index_digitallib
    item = Gwboard::Synthesis.new
    item.digitallibrary_readable_syntheses(@date)
    items = item.find(:all, 
      :select => 'latest_updated_at',
      :order => 'gwboard_syntheses.latest_updated_at DESC')
    
    if items.length > 0
      @digitallib_docs = "#{@msg} #{items.length}件の更新あり。最新記事は [ #{items[0].latest_updated_at.strftime('%Y年%m月%d日 %H時%M分').to_s} ] に更新。"
    end
  end
end
