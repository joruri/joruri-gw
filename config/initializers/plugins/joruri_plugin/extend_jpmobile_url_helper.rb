# encoding: utf-8
module ActionView
  module Helpers
    #link_to の第二引数にStringを指定した場合、trans_idが引数で渡されないので修正
    module UrlHelper
      alias :url_for_without_jpmobile :url_for
      def url_for(options = {})
        url = url_for_without_jpmobile(options)
        @controller = request.env["action_controller.instance"] if @controller.blank?
        if options.kind_of?(String) and @controller and @controller.trans_sid_mode
          skey = request.session_options[:key]
          sid  = request.session_options[:id] rescue session.session_id
          skey = "_session_id" if skey.blank?
          unless options =~ /#{skey}/
            #jpmobile_url = URI.parse(url)
            #URL形式でない場合はそのまま返す
            begin
              jpmobile_url = URI.parse(url)
            rescue URI::InvalidURIError
              return url.to_s
            end
            #携帯からのリクエストでない場合は付与しない
            return jpmobile_url.to_s unless request.mobile?
            #Cookie対応端末には付与しない
            return jpmobile_url.to_s if request.mobile.supports_cookie?
            if jpmobile_url.query
              jpmobile_url.query += "&#{skey}=#{sid}"
            else
              jpmobile_url.query = "#{skey}=#{sid}"
            end
            url = jpmobile_url.to_s
          end
        end
        return url
      end
    end
  end
end
