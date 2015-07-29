# encoding: utf-8
module Gw::Controller::Public

  def self.included(mod)
    mod.before_filter :access_control
  end

  def access_control
    if (Site.user && Site.user.code == 'gwsys1151')
      if !(request.env['PATH_INFO'] =~ /^\/*gw\/maa\_/ ||
        (request.env['PATH_INFO'] =~ /^\/*gwbbs/ && request.env['QUERY_STRING'] =~ /title_id=50/) ||
        request.env['PATH_INFO'] =~ /^\/*logout/)

        return respond_to do |format|
          format.html {
            Site.format = 'html'
            redirect_url = "/gw/maa_schedule_props/show_week?s_genre=facility&cls=bs"
            redirect_to(redirect_url)
          }
        end
      end
    else

      _cond = "class_id=3 and name='pref_only_assembly' and type_name='account' "
      _order = "class_id desc"
      only_pref_account   = Gw::UserProperty.find(:first , :conditions=>_cond ,:order=>_order)
      if only_pref_account.blank?
        only_assembly_user_account = '502'
      else
        only_assembly_user_account = only_pref_account.options
      end

      if !Site.user.blank? && Site.user.code.to_s == only_assembly_user_account.to_s
        if !(request.env['PATH_INFO'] =~ /^\/*gw\/pref_only_assembly/ ||
          request.env['PATH_INFO'] =~ /^\/*gw\/pref_only_directors/ ||
          request.env['PATH_INFO'] =~ /^\/*gw\/pref_only_executives/ ||
          request.env['PATH_INFO'] =~ /^\/*logout/)
          redirect_to('/gw/pref_only_assembly')
        else
        end
      end
    end

  end

end
