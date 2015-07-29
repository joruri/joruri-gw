# encoding: utf-8
module Gwbbs::Admin::Piece::MenusHelper

  def gwbbs_sidelist_title
    str = ''
    case params[:state]
    when "TODAY"
      str = '(本日登録分)'
    when "DATE"
      str = '(日付別)'
    when "GROUP"
      str = '(所属別)'
    when "CATEGORY"
      str = '(分類別)'
    when "DRAFT"
      str = '(下書き一覧)'
    when "RECOGNIZE"
      str = '(承認待ち一覧)'
    when "PUBLISH"
      str = '(公開待ち一覧)'
    when "NEVER"
      str = '(公開前一覧)'
    when "VOID"
      str = '(期限切れ一覧)'
    when "ALL"
      str = '(全記事一覧)'
    else
      str = '(日付別)'
    end
    return str
  end
end
