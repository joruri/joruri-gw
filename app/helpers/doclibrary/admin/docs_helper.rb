module Doclibrary::Admin::DocsHelper

  def new_doclib_category_qstring()
    return "&cat=#{params[:cat]}"
  end

  def folder_doclib_category_qstring(item)
    ret = "?title_id=#{item.title_id}"
    ret += "&state=#{params[:state]}"
    ret += "&gcd=#{item.code}" if params[:state] == 'GROUP'
    ret += "&cat=#{item.id}" unless params[:state] == 'GROUP'
    ret += "#{ret}&limit=#{params[:limit]}" unless params[:limit].blank?
    return ret
  end

  def doclib_uri_params
    state = params[:state]
    base_path = "&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def doclibrary_show_uri(item,prms=nil)
    if prms.blank?
      state = 'CATEGORY'
    else
      state = prms[:state]
    end
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}" if state == 'GROUP'
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}" if state == 'DATE'
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}&cat=#{item.category1_id}" unless state == 'GROUP' unless state == 'DATE'
    return ret
  end

end
