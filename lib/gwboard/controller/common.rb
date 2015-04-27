module Gwboard::Controller::Common

  def gwbbs_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?
    str += "&kwd=#{params[:kwd]}" unless params[:kwd].blank?
    return str
  end

  def initialize_value_set
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    unless Core.request_uri.index("doclibrary")
      @css = ["/_common/themes/gw/css/gwboard/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
    else
      @css = ["/_common/themes/gw/css/gwboard/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]
    end

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end

  def initialize_value_set_new_css
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    s_kwd = params[:kwd]
    s_kwd = s_kwd.gsub(/　/,'').strip unless s_kwd.blank?
    params[:kwd] = nil if s_kwd.blank?

    unless Core.request_uri.index("doclibrary")
      unless params[:preview].blank?
        css_path = "/_attaches/css/preview/#{@title.system_name}/#{@title.id}.css"
      else
        css_path = "/_attaches/css/#{@title.system_name}/#{@title.id}.css"
      end
      f_path = "#{Rails.root}/public/#{css_path}"
      if FileTest.exist?(f_path)
        @css = [css_path, "/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      else
        @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column.css"]
      end
    else
      @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]
    end

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end

  def initialize_value_set_new_css_dl
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    params[:limit] = @title.default_limit.to_s if params[:limit].to_i < 1
    params[:limit] = @title.default_limit.to_s if 100 < params[:limit].to_i

    @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css", "/_common/themes/gw/css/doc_2column_dl.css"]

    @img_path = "public/_common/modules/#{@title.system_name}/"
  end
end
