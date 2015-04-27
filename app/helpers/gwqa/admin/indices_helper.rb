module Gwqa::Admin::IndicesHelper

  def gwqa_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?
    str += "&limit=#{params[:limit]}" unless params[:limit].blank?
    str += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return str
  end
end
