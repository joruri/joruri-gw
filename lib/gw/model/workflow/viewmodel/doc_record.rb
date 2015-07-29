# encoding:utf-8

# 一覧表示のレコード
class Gw::Model::Workflow::Viewmodel::DocRecord
  attr_reader :id, :title, :expired_at, :applied_at, :updated_at, :state
  def initialize params={}
    @id = params[:id]
    @state = params[:state]
    @title = params[:title]
    @progress = params[:progress]
    @expired_at = params[:expired_at]
    @applied_at = params[:applied_at]
    @updated_at = params[:updated_at]
  end
  def progress_den # 分母
    @progress[:den]
  end
  def progress_num # 分子
    @progress[:num]
  end
  
  def state_str
    case @state.to_sym
    when :draft then '下書き'
    when :applying then '処理中'
    when :remanded then '差し戻し'
    when :accepted then '決裁'
    when :rejected then '却下'
    else '不明'
    end
  end
  def progress_str
    "(#{@progress[:num]}/#{@progress[:den]})"
  end
end