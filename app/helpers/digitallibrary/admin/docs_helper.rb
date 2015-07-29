module Digitallibrary::Admin::DocsHelper

  def new_digitallib_qstring()
    ret = ""
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    return ret
  end

  def folder_digitallib_qstring(item)
    ret = "?title_id=#{item.title_id}&cat=#{item.id}"
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    return ret
  end

  def digitallib_uri_params
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def cat_params(item)
     return "" if item.blank?
     return "&cat=#{item.parent_id.to_s}" unless item.parent_id.blank?
     return "&cat=#{item.id}"
  end

end
