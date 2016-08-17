module Digitallibrary::Admin::DocsHelper

  def digitallib_uri_params(category=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    base_path = "&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{category || params[:cat]}"
    end
    return ret
  end

  def cat_params(item)
     return "" if item.blank?
     return "&cat=#{item.id}" if item.doc_type == 1
     return "&cat=#{item.parent_id.to_s}" unless item.parent_id.blank?
     return "&cat=#{item.id}"
  end
end
