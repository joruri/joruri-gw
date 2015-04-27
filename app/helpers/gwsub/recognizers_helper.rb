module Gwsub::RecognizersHelper
  def gwsub_recognizer_form(form, item)
    render 'gwsub/admin/recognizers/form', f: form, item: item
  end

  def gwsub_recognizers_list_form(form, item)
    render 'gwsub/admin/recognizers_list/form', f: form, item: item
  end

  #
  def gwsub_state_to_partial_name
    ret = 'show_header_normal'
    case params[:state].to_s
    when "RECOGNIZE"
      ret =  'show_header_recognize'
    when "PUBLISH"
      ret =  'show_header_publish'
    end
    return ret
  end

    #------承認ボタンの表示判別↓----------
  #ログインユーザーに承認依頼されている申請書があるか
  def search_recognize_user(item)
    item.and :parent_id, params[:id]
    item.and :user_id, Core.user.id
    items = item.find(:all)
    ret = nil
    ret = true if items.length != 0
    return ret
  end

end
