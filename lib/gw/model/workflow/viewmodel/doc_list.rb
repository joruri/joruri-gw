# encoding:utf-8

# 一覧表示Viewのためのモデル
class Gw::Model::Workflow::Viewmodel::DocList
  attr_accessor :records
  def initialize
    @records = [] # Gw::Model::Workflow::ViewModel::DocRecord の配列が入る予定
  end
end

