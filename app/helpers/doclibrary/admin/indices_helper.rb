module Doclibrary::Admin::IndicesHelper

  def doclib_params_set_index
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return ret
  end

  def doclib_params_set
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return ret
  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end
end
