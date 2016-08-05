module Gwbbs::Admin::DocsHelper

  def doc_size_usage_rate
    body_size_capacity = 0
    body_size_currently = 0
    body_size_capacity = @title.doc_body_size_capacity unless @title.doc_body_size_capacity.blank?
    body_size_currently = @title.doc_body_size_currently unless @title.doc_body_size_currently.blank?
    msg = ""
    return msg if body_size_capacity == 0
    return msg if body_size_currently == 0
    usage = 0
    usage = body_size_currently.to_f / body_size_capacity.megabytes.to_f unless body_size_capacity.megabytes.to_f == 0
    usage = usage * 100
    msg = "　記事本文使用量 #{body_size_currently}バイト" if usage < 1
    msg = "　記事本文容量利用率 #{sprintf('%.04g', usage)}%" if 1 <= usage
    msg = required("<br />#{msg} 　※制限値に近付いています。　不要な記事を削除するか、管理者に連絡してください。") if 90 < usage if usage <= 99.9999
    msg = required("<br />#{msg} 　※制限値を超過しました。　不要な記事を削除するか、管理者に連絡してください。") if 100 <= usage
    return msg
  end

  def admin_doc_size_usage_rate
    body_size_capacity = 0
    body_size_currently = 0
    body_size_capacity = @item.doc_body_size_capacity unless @item.doc_body_size_capacity.blank?
    body_size_currently = @item.doc_body_size_currently unless @item.doc_body_size_currently.blank?
    msg = ""
    return msg if body_size_capacity == 0
    return msg if body_size_currently == 0
    usage = 0
    usage = body_size_currently.to_f / body_size_capacity.megabytes.to_f unless body_size_capacity.megabytes.to_f == 0
    usage = usage * 100
    msg = "　記事本文使用量は #{body_size_currently}バイトです。" if usage < 1
    msg = "　記事本文利用率は #{sprintf('%.04g', usage)}%です。"  if 1 <= usage
    msg = required(" ※#{msg} 制限値に近付いています。") if 90 < usage if usage <= 99.9999
    msg = required(" ※#{msg} 制限値を超過しました。") if 100 <= usage
    return msg
  end

end
