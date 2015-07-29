# encoding: utf-8

# mobile_filter
Rails.application.config.jpmobile.mobile_filter
Rails.application.config.jpmobile.form_accept_charset_conversion = true

module Jpmobile
  module RequestWithMobile
    def mobile?
      mobile
    end
  end
end

module Jpmobile::Mobile
  class Docomo < AbstractMobile
    def default_charset
      "UTF-8"
    end
    def to_internal(str)
      str
    end
    def to_external(str, content_type, charset)
      [str, charset]
    end
  end
end

module Jpmobile
  module Util
    module_function
    def sjis(str)
      if str.respond_to?(:force_encoding) and !shift_jis?(str)
        str = NKF.nkf('-s -x --oc=CP932', str)
        str.force_encoding(SJIS)
      end
      str
    end
    def utf8(str)
      if str.respond_to?(:force_encoding) and !utf8?(str)
        str = NKF.nkf('-w', str)
        str.force_encoding(UTF8)
      end
      str
    end
    def jis(str)
      if str.respond_to?(:force_encoding) and !jis?(str)
        str = NKF.nkf('-j', str)
        str.force_encoding(JIS)
      end
      str
    end
  end
end

module Jpmobile::Mobile
  class Docomo < AbstractMobile
    def supports_cookie?
      imode_browser_version != '1.0' && imode_browser_version !~ /^2.0/
    end
  end
end

case Joruri.config.application['sys.force_site']
when 'mobile'
  module Jpmobile::Mobile
    class Others < SmartPhone
      USER_AGENT_REGEXP = /./
    end
  end
  module Jpmobile::Mobile
    @carriers << 'Others'
  end
when 'pc'
  module Jpmobile::Mobile
    @carriers = []
  end
end