# -*- encoding: utf-8 -*-
class Gw

  def self.nz(value, valueifnull='')
    value.blank? ? valueifnull : value
  end

  def self.version
    return Joruri.version
  end

  def self.br(str)
    str.to_s.gsub(/\r\n|\r|\n/, '<br />')
  end

  def self.required_head
    required '※は必須項目です。'
  end

  def self.required(str='※')
    %Q( <span class="required">#{str}</span>).html_safe
  end

  def self.user_groups_error
    %Q(<span style="color: red;">** 所属未登録 **</span>).html_safe
  end

  def self.nobr(str)
    %Q(<span class="nobr">#{str}</span>)
  end

  def self.as_array(x)
    x.blank? ? [] :
      x.is_a?(Array) ? x :
      x.is_a?(String) ? x.split(':') :
        x.to_s.split(':')
  end

  def self.div_notice(str, options={})
    class_s = nz(options[:class], 'notice')
    id_s = options[:id].blank? ? '' : " id='#{options[:id]}'"
    %Q(<div#{id_s} class="#{class_s}">#{str}</div>).html_safe
  end

  def self.add_info(cls, title)
    item = Gw::Info.new({ :cls=>cls, :title=>title })
    item.save
  end

  def self.add_memo(uids, title, body, options={})
    uids = uids.to_s.split(':') if !uids.is_a?(Array)
    uids = uids.uniq
    fr_u = options[:fr_user].blank? ? Core.user : System::User.find(:first, :conditions=>"id=#{options[:fr_user]}") rescue Core.user
    fr_u = Core.user if fr_u.blank?
    begin
      Gw::Database.transaction do
        memo = {
          :class_id=>1,
          :uid=>fr_u.id,
          :title=>title,
          :ed_at=>nz(options[:ed_at],Gw.datetime_str(Time.now)),
          :is_finished=>options[:is_finished],
          :is_system=>options[:is_system],
          :fr_group=>fr_u.groups[0].name,
          :fr_user=>fr_u.display_name,
          :body=>body
        }
        item = Gw::Memo.new(memo)
        item.save!
        uids.each do |uid|
          memo_user = Gw::MemoUser.new({
            :schedule_id => item.id,
            :class_id => 1,
            :uid => uid
          })
          memo_user.save!
        end
        item.send_mail_after_addition uids
      end
      return true
    rescue => e
      case e.class.to_s
      when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
      else
        raise e
      end
      return false
    end
  end

  def self.send_mail(mail_fr, mail_to, subject, message)
    System::Controller::Mail::Smtp.default_mail(mail_fr, mail_to, subject, message).deliver
  end

  def self.error_div(errors)
    ret = nil
    unless errors.nil?
      ret = %Q(<div class="errorExplanation" id="errorExplanation"><h2>#{errors.length}個のエラーが発生しました。</h2><p>次の項目を確認してください。</p><ul>)
      errors.each do |error|
        ret += %Q(<li>#{error[1]}</li>)
      end
      ret += '</ul></div>'
    end
    ret
  end

  def self.alternate_uri(uri, options={})
    alert_message = options[:alert_message].nil? ? '' : '開発中です。'
    uc = if defined?(WDB) || options[:mode] == 'wdb'
      "javascript:alert(#{alert_message.to_json } + #{"\n".to_json } + #{uri.to_json});"
    else
      '/under_construction.html'
    end
    return RAILS_ENV == 'development' && options[:force_uc].nil? && !uri.blank? ? uri : uc
  end

  def self.link_to_uc(caption, uri=nil, options={})
    helperx.link_to_uc(caption, uri, options)
  end

  def self.link_to_uc_for_hm(img_filename, caption, uri=nil, options={})
    image_uri_base = nz(options[:image_uri_base], '/_common/themes/gw/files/hm/')
    image_uri = (/\// =~ img_filename).nil? ? "#{image_uri_base}#{img_filename}" : uri
    width = nz(options[:width], 30)
    height = nz(options[:height], 30)
    cap_arg = %Q(<img width="#{width}" height="#{height}" border="0" src="#{image_uri}" title="#{caption}" alt="#{caption}" /><br />#{caption})
    ret = %Q[<li>#{Gw.link_to_uc cap_arg, uri}</li>]
    ret
  end

  def self.links_to_uc(captions)
    captions.collect{|x| "<li>#{Gw.link_to_uc x}</li>"}.join
  end

  def self.links_to_uc_ext(captions)
    captions.collect{|x| "<li>#{Gw.link_to_uc x, nil, :class=>:ext, :target=>:blank}</li>"}.join
  end

  def self.links_to_ext_with_uri(captions)
    ret = []
    captions.each_slice(2){|x| ret.push "<li>#{helperx.link_to x[0], x[1], :class=>:ext, :target=>:blank}</li>"}
    ret.join
  end

  def self.links_to_pref_cms(yaml_key = 'sso_pref_portal_joruricms')
    ret = []
    dat = Gw.yaml_to_array_for_select(yaml_key).collect{|x|
      w = x[0].split ' '
      [x[1], *w]
    }
    dat.each{|x| ret.push(
      "<li>#{helperx.link_to x[1], "/_admin/gw/test/#{x[0]}/redirect_pref_cms", :class=>:ext, :target=>'_blank'}</li>"
      )}
    ret.join
  end

  def self.links_to_pref_portal(yaml_key = 'sso_pref_portal_joruricms')
    ret = []
    dat = Gw.yaml_to_array_for_select(yaml_key).collect{|x|
      w = x[0].split ' '
      [x[1], *w]
    }
    dat.each{|x| ret.push(
      "#{helperx.link_to x[1], "/_admin/gw/test/#{x[0]}/redirect_pref_cms",  :target=>'_blank'}"
      )}
    ret.join
  end

  def self.caller(idx = 0)
    Kernel.caller.grep(/gw/)[idx]
  end

  def self.check_nil(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      here = Gw.caller 1
        alt
    end
  end

  def self.ie?(request)
    !request.blank? && !request.user_agent.blank? && !request.user_agent.index("MSIE").blank?
  end

  def self.simple_strip_html_tags(html, options={})
    exclude_tags = nz(options[:exclude_tags], [])
    exclude_tags = exclude_tags.split(':') if exclude_tags.is_a?(String)
    ret = html.gsub(/\<(.+?)\>/){ exclude_tags.index($1).nil? ? '' : $& }
    ret
  end

  def self.weekday_s(d, _options={})
    options = HashWithIndifferentAccess.new(_options)
    mode = nz(options[:mode], 'j').to_s
    holidays = options[:holidays] || '' if options.key?(:holidays)
    return self.holiday?(d,
      :no_weekend=>1,
      :holidays=>holidays
      ) ? [%w(j 祝), %w(el holiday), %w(eh holiday)].assoc(mode)[1] :
      self.weekday(d.wday,mode)
  end

  def self.weekday(w, mode='j')
    case mode
    when 'j'
      wa = [[0,'日'],[1,'月'],[2,'火'],[3,'水'],[4,'木'],[5,'金'],[6,'土'],]
    when 'el' # english long
      wa = [[0,'sunday'],[1,'monday'],[2,'tuesday'],[3,'wednesday'],[4,'thursday'],[5,'friday'],[6,'saturday'],]
    when 'eh' # english for holiday
      wa = [[0,'sunday'],[1,'weekday'],[2,'weekday'],[3,'weekday'],[4,'weekday'],[5,'weekday'],[6,'saturday'],]
    else
      raise TypeError, 'mode 指定が異常です'
    end
    wa.assoc(w)[1]
  end

  def self.holiday?(d = Time.now, _options={})
    options = HashWithIndifferentAccess.new(_options)
    is_weekend = ![0,6].index(d.wday).nil?

    is_holiday = false
    if options.key?(:holidays)
      if !options[:holidays].blank?
       options[:holidays].each{|x|
         if Gw.date_str(x.st_at) == Gw.date_str(d)
            is_holiday = true
           break;
         end
        }
      end
    else
      hs = Gw::Holiday.find(:all, :conditions=>"st_at='#{Gw.date_str(d)}'")
      is_holiday = hs.length > 0
    end

    ret = false
    ret = ret || is_weekend if nf(options[:no_weekend]).blank?
    ret = ret || is_holiday if nf(options[:no_holiday]).blank?
    return ret
  end

  def self.extract_holidays(dates)
    weekdays, holidays = [], []
    dates.each{|d|
      if self.holiday?(d)
        holidays.push d
      else
        weekdays.push d
      end
    }
    return [weekdays, holidays]
  end

  #require 'jcode'
  def self.left(str, length)
    return str if length >= str.jlength
    str_wrk = str.split(//)
    str_wrk.slice(0,length).join
  end
  def self.right(str,length)
    return str if length >= str.jlength
    str_wrk = str.split(//)
    str_wrk.slice(str.jlength - length,length).join
  end
  def self.chop_str(str, length = 100, mode = 0, postfix = "...")
    case mode
    when 1
      str_wrk = str.split(//)
      p1 = nz(str_wrk.index("、"),0)
      p2 = nz(str_wrk.index("。"),0)
      if p1 == 0 && p2 == 0
        ret = left(str, length)
      elsif p2 == 0
        ret = left(str, p1 + 1)
      elsif p1 == 0
        ret = left(str, p2 + 1)
      else
        p = p1 > p2 ? p2 : p1
        ret = left(str, p+1)
      end
      ret += postfix if str != ret
      ret
    else
      ret = left(str, length)
      ret += postfix if str != ret
      ret
    end
  end
  def self.modelize(table_name)
    table_name.singularize.split('_').collect{|x| x.capitalize}.join('::')
  end
  def self.tablize(model_name)
    model_name.pluralize.underscore.gsub('/', '_')
  end
  def self.chop_with(str, suffix)
    return str.ends_with?(suffix) ? Gw.left(str, str.length - suffix.length) : str
  end
  def self.ablize(str)
    chop_with(str, 'e') + 'able'
  end
  def self.get_marubatsu(bool)
    bool ? '○' : '×'
  end
  def self.idize(str, options={})
    ret = str.gsub('[', '_').gsub(']', '')
    ret = ret.gsub('(','_').gsub(')','') if options[:no_small_parenthesis].blank?
    return ret
  end
  class << self
    alias :name_to_id :idize
  end

  def self.trim(s)
    nz(s).to_s.gsub(/^[\r\n\t\f\v 　]+/,'').gsub(/[\r\n\t\f\v 　]+$/,'')
  end

  def self.zenhan(s)
    NKF.nkf('-eZw', s) # eZ: zenhan w: assumes utf8
  end

  def self.hanzen(s)
    s.nil? ? '' : s.tr("A-Z0-9","Ａ-Ｚ０-９")
  end

  def self.half_width_characters?(string)
    # 半角英数字、および半角アンダーバーのチェック
    if string =~  /^[0-9A-Za-z\_]+$/
      return true
    else
      false
    end
  end

  def self.get_uniq_data(a = [])
    # 重複したデータを配列として返す
    return a.uniq.select{|i| a.index(i) != a.rindex(i)}
  end

  def self.is_valid_email_address?(v)
    # logic: based.on ValidatesEmailFormatOf
    options = { :check_mx => false,
      :with => ValidatesEmailFormatOf::Regex }
    begin
      domain, local = v.reverse.split('@', 2)
    rescue
      return 0
    end
    if domain.blank?
      return 0
    end
    if local.blank?
      return 0
    end
    unless (domain.length <= 255 and local.length <= 64)
      return 0
    end
    if  v =~ /\.\./
      return 2
    end
    unless v =~ options[:with]
      return 2
    end
    if options[:check_mx]
      return 2 unless
        ValidatesEmailFormatOf::validate_email_domain(v)
    end
    return 1
  end

  def self.is_simplicity_valid_email_address?(email)
    begin
      domain, local = email.reverse.split('@', 2)
    rescue
      return false
    end
    if domain.blank?
      return false
    end
    if local.blank?
      return false
    end
    unless (domain.length <= 255 and local.length <= 64)
      return false
    end
    return true
  end

  def self.get_temp_filename(params)
    File.join(RAILS_ROOT, 'tmp', "#{params[:controller].gsub('/', '_')}_#{params[:action]}_#{Core.user.id}_#{Time.now.strftime("%Y%m%d%H%M")}")
  end

  def self.float?(s)
    ret = (/^[-+]?((\d+)?(\.\d+))|((\d+)(\.\d+)?)([eE][-+]\d+)?$/ =~ s.to_s)
    ret ? true : false
  end

  def self.int?(s)
    ret = (/^[-+]?(\d+)$/ =~ s.to_s)
    ret ? true : false
  end

  class << self
    alias :is_float? :float?
    alias :is_int? :int?
  end

  def self.to_float(s)
    return s.to_f if is_float?(s)
    raise "fail at convert string to float"
  end

  def self.to_int(s)
    return s.to_i if is_int?(s)
    raise "fail at convert string to int"
  end

  def self.a_to_qs(qs_a, options={})
    return '' if qs_a.nil?
    return "?#{qs_a}" if qs_a.is_a?(String)
    delim = options[:no_entity].blank? ? '&amp;' : '&'
    qs_s = qs_a.join(delim)
    qs_s = "?#{qs_s}" if !qs_s.blank?
  end

  def self.a_in_nil(ary = [], cnt = 1)
    len = ary.length
    return ary if len >= cnt
    while len < cnt
      ary << nil
      len += 1
    end
    return ary
  end

  def self.qsa_to_qs(qsa, options={})
    delim = options[:no_entity].blank? ? '&amp;' : '&'
    qsa.collect{|x| %Q(#{x[0]}=#{x[1]})}.join(delim)
  end

  def self.qs_to_qsa(qs, options={})
    delim = options[:no_entity].blank? ? '&amp;' : '&'
    qs.split(delim).collect{|x| _x = x.split('='); [_x[0], _x[1]]}
  end
  def self.params_to_qsa(keys, params, options={})
    keys.delete_if{|x| nz(params[x],'')==''}.collect{|x| [x, params[x]]}
  end

  def self.is_deco_cloud?(gid=Core.user_group.id)
    group = System::Group.find_by_id(gid)
    return false if group.blank?
    p_group = System::Group.find_by_id(group.parent_id)
    return false if p_group.blank?
    return true
  end

  def self.is_deco_pref?(gid=Core.user_group.id)
    group = System::Group.find_by_id(gid)
    return false if group.blank?
    p_group = System::Group.find_by_id(group.parent_id)
    return false if p_group.blank?
    return false
  end

  def self.is_dev?(options={})
    uid = nz(options[:uid],Core.user.id)
    System::Model::Role.get(1, uid ,'gwsub', 'developer')
  end

  def self.is_editor?(options={})
    uid = nz(options[:uid],Core.user.id)
    editor_users        = System::Model::Role.get(1, uid ,'system_users','editor')
    editor_tabs         = System::Model::Role.get(1, uid ,'edit_tab', 'editor')
    editor_rss          = System::Model::Role.get(1, uid ,'rss_reader', 'admin')
    editor_blogparts    = System::Model::Role.get(1, uid ,'blog_part', 'admin')
    editor_ind_portals  = System::Model::Role.get(1, uid ,'ind_portal', 'admin')
    admin_disaster      = Gw::AdminMode.is_disaster_admin?( uid )
    editor_disaster     = Gw::AdminMode.is_disaster_editor?( uid )
    editor = editor_users || editor_tabs  || editor_rss || editor_blogparts || editor_ind_portals || admin_disaster || editor_disaster
    return editor
  end

  def self.is_admin_admin?(options={})
    uid = nz(options[:uid],Core.user.id)
    ret = System::Model::Role.get(1,uid,'_admin','admin')
    return ret
  end

  def self.is_admin_or_editor?(options={})
    uid = nz(options[:uid],Core.user.id)
    editor = Gw.is_editor?(options)
    admin = Gw.is_admin_admin?(options)
    admin_role = editor || admin
    return admin_role
  end

  #require 'parsedate'
  def self.get_parsed_date(datestr)
    case datestr.class.to_s
    when 'Time'
      return datestr
    when 'Date'
      return date_to_time(datestr)
    when 'String'
      begin
        w1 = DateTime.parse(datestr)
      rescue # 日付が異常、もしくは日付が存在しない場合
        raise ArgumentError, '存在しない日付です'
        return false
      else
        return w1
      end
    end
  end

  def self.date_common(d, value_if_err='!!!')
     datetime_str(d, value_if_err)
  end

  def self.datetime_str(d, value_if_err='!!!')
    begin
      return d.strftime("%Y-%m-%d %H:%M")
    rescue
      return (value_if_err == '!!!' ? d.to_s : value_if_err.to_s )
    end
  end

  def self.date_str(d, value_if_err='!!!')
    begin
      return d.strftime("%Y-%m-%d")
    rescue
      return (value_if_err == '!!!' ? d.to_s : value_if_err.to_s )
    end
  end

  def self.time_str(d, value_if_err='!!!')
    begin
      return d.strftime("%H:%M")
    rescue
      return (value_if_err == '!!!' ? d.to_s : value_if_err.to_s )
    end
  end

  def self.date8_str(d, value_if_err='!!!')
    begin
      return d.strftime("%Y%m%d")
    rescue
      return (value_if_err == '!!!' ? d.to_s : value_if_err.to_s )
    end
  end

  def self.date_between_helper(date_field, d1, d2=nil)
    d2 = d1 if d2.nil?
    [d1,d2].each do |d|
      if d.is_a?(Date) || d.is_a?(DateTime) || d.is_a?(Time)
      else
        raise TypeError, "unknown type(#{d1.class})" if d1.class.to_s != 'Date'
      end
    end
    return %Q(#{date_field} between '#{d1.strftime('%Y-%m-%d 0:0:0')}' and '#{d2.strftime('%Y-%m-%d 23:59:59')}')
  end

  def self.date_array(d1,d2)
    ret = []
    for d in datetime_to_date(d1)..datetime_to_date(d2)
      ret.push d
    end
    return ret
  end

  def self.datetime_to_date(dt)
    #Time.local(dt.year, dt.month, dt.day)
    Date::new(dt.year, dt.month, dt.day)
  end

  def self.date_to_time(dt, options={})
    _default_time = [8, 30, 0]
    _default_time = options[:initialize_time] if options[:initialize_time] && options[:initialize_time].size >= 3
    Time.local(dt.year, dt.month, dt.day, _default_time[0], _default_time[1], _default_time[2])
  end

  def self.datetimediff(d1, d2, options={})
    return nil if d1.nil? || d2.nil?
    d1x = get_parsed_date(d1)
    d2x = get_parsed_date(d2)
    if nz(options[:ignore_time], false)
      d1x = Time.local(d1x.year, d1x.month, d1x.day)
      d2x = Time.local(d2x.year, d2x.month, d2x.day)
    end
    ret = (d2x - d1x) / 86400
    return nz(options[:ignore_time], false) ? ret.to_i : ret
  end

  def self.order_last_null(fld, options={})
    order = options[:order] || 'asc'
    order.downcase!
    order = %w(asc desc).index(order).nil? ? 'asc' : order
    mode = options[:mode] || 2
    case mode
    when 1
      return "coalesce(#{fld}, '2036-12-31') #{order}"
    when 2
      return "#{fld} is null asc, #{fld} #{order}"
    else
      raise ArgumentError, ':mode は 1, 2 のみが指定できます。'
    end
  end

  def self.date_in_range?(d, d1, d2)
    d = datetime_to_date(d)
    d1 = datetime_to_date(d1)
    d2 = datetime_to_date(d2)
    return d1 <= d && d <= d2
  end

  def self.is_valid_date_str?(datestr)
    return false if datestr.nil?
    dx = Date.new(datestr)
    return false if dx[0].nil? || dx[1].nil? || dx[2].nil?
    Date.valid_date?(dx[0], dx[1], dx[2])
  end

  def self.date_format(format, d)
    return '' if d.nil?
    f = format.dup
    f.sub!(/%_m/, "#{d.month}")
    f.sub!(/%_d/, "#{d.day}")
    if f =~ /%_wd\{(.+)\}/
      wd = $1
      f.sub!(/%_wd\{(.+)\}/, self.weekday(d.wday, wd))
    end
    f.sub!(/%_wd/, self.weekday(d.wday))
    d.strftime(f)
  end

  def self.int_format(format, *ary)
    return '' if ary.blank?
    f = format.dup
    idx = 0
    %w(%,d).each {|r|
      d = ary[idx]
      f.sub!(/#{r}/, int_format_ind(r, d))
      idx += 1
    }
    f
  end

  def self.int_format_ind(format, d)
    return '' if d.nil?
    return d if !Gw.int?(d)
    f = format.dup
    case f
    when '%d'
      format % d
    when '%,d'
      str = d.to_s
      tmp = ""
      while (str =~ /([-+]?.*\d)(\d\d\d)/) do
        str = $1
        tmp = ",#{$2}" + tmp
      end
      str + tmp
    end
  end

  def self.dateand(_mdl, fld, date_s)
    cri_s = dateand_core(date_s)
    _mdl.and fld, 'between', cri_s unless cri_s.nil?
  end

  def self.dateand_where(fld, date_s)
    cri_s = dateand_core(date_s)
    return cri_s.nil? ? nil : "#{fld} between #{cri_s}"
  end

  def self.dateand_core(date_s)
    return nil if trim(date_s).nil?
    w = Date.new(date_s.gsub('-', '/'))
    td = Date.today
    ty = td.year
    tm = td.month
    y, m, d = w[0..2]
    if w[0].nil?
      if w[1].nil?
        if w[2].nil?
          return nil
        else
          d1 = Date.new(ty, tm, d)
          d2 = d1
        end
      else
        if w[2].nil?
          d1 = Date.new(ty, m, 1)
          d2 = Date.new(ty, m, -1)
        else
          d1 = Date.new(ty, m, d)
          d2 = d1
        end
      end
    else
      if w[1].nil?
        if w[2].nil?
          d1 = Date.new(y, 1, 1)
          d2 = Date.new(y, 12, 31)
        else
          return nil
        end
      else
        if w[2].nil?
          d1 = Date.new(y, m, 1)
          d2 = Date.new(y, m, -1)
        else
          d1 = Date.new(y, m, d)
          d2 = d1
        end
      end
    end
    return "'#{d1.year}-#{d1.month}-#{d1.day} 0:0:0' and '#{d2.year}-#{d2.month}-#{d2.day} 23:59:59'"
  end

  def self.date8_to_date(s=nil, options={})
    default = options[:default]
    default = Date.today if default.nil?
    return default if s.nil?
    ret = s =~ /[0-9]{8}/ ? Date.strptime(s, '%Y%m%d') : default
    return options[:to_s].nil? ? ret : datetime_str(ret)
  end

  def self.ym_to_time(d, options={})
    return nil if d.blank?
    d_a = Date.new(d)
    day = options[:day].blank? ? 1 : options[:day]
    d_a.blank? || d_a[0].blank? || d_a[1].blank? ? nil :
      day > 0 ? Time.local(d_a[0], d_a[1], day) : Time.local(d_a[0], d_a[1]).end_of_month
  end

  def self.extract_datetime_param!(params, keys)
    item = params[:item]
    keys.each{|key|
      item[key] = Time.local *((1..5).collect{|x|
        kn = "#{key}(#{x}i)";
        y = item[kn];
        item.delete kn
        y
      })
    }
  end

  def self.checkbox_to_string(hx, options={})
    delim = nz(options[:delim], ':')
    hx.is_a?(Hash) ? hx.to_a.sort.collect{|k,v| v}.join(delim) : hx
  end

  def self.to_time(_dt)
    case _dt.class.to_s
    when 'Date', 'Time', 'DateTime'
      return _dt.to_time
    when 'String'
      begin
        dt = DateTime.parse(_dt)
      rescue # 日付が異常、もしくは日付が存在しない場合
        raise TypeError, "日付が異常、もしくは日付が存在しません"
      else
        return dt
      end
    else
      raise TypeError, "未知の型です(#{_dt.class})"
    end
  end

  def self.datetime_merge(_d, _t)
    d = Gw.to_time(_d)
    t = Gw.to_time(_t)
    return Time.local(d.year, d.month, d.day, t.hour, t.min, t.sec)
  end

  def self.mkdir_for_file(path)
    mode_file = !path.ends_with?('/')
    px = path.split(/\//)
    dir_name = px[0, px.length - (mode_file ? 1 : 0)].join(File::Separator)
    ret = true
    begin
      FileUtils.mkdir_p(dir_name) unless File.exist?(dir_name)
    rescue
      ret = false
    end
    return ret
  end

  def self.dir_exists?(path)
    File.exists?(path) && File::ftype(path) == "directory"
  end

  def self.load_yaml_files_cache(glob = nil)
    c_key = "Gw.load_yaml_files_" + glob.to_s
    begin
        value = Rails.cache.read(c_key)
        if value.blank?
          value = self.load_yaml_files(glob)
          Rails.cache.write(c_key, value, :expires_in => 3600)
        else
        end
    rescue
        value = self.load_yaml_files(glob)
    end
    return value
  end

  def self.load_yaml_files(glob = nil)
    ret = {}
    glob = "#{Rails.root}/config/locales/table_field*.yml" if glob.nil?
    Dir[glob].each do |dir|
      ret.merge! YAML.load_file(dir)
    end
    ret
  end

  def self.join(obj, delim='')
    if obj.is_a?(Array)
      delete_blank(obj).join(delim)
    else
      obj.join delim
    end
  end

  def self.delete_blank(obj)
    if obj.is_a?(Array)
      obj.reject{|x| x.blank?}
    else
      obj
    end
  end

  def self.delete_nil(obj)
    if obj.is_a?(Array)
      obj.compact
    else
      obj
    end
  end

  def self.extract(hx, options={})
    keys = options[:keys]
    return nil if keys.nil?
    ret = ::HashWithIndifferentAccess.new(hx)
    ret.keys.each {|key|
      ret.delete key if keys.index(key).nil?
    }
    ret
  end

  def self.validates_datetime(v, _options={})
    options = HashWithIndifferentAccess.new({
      :allow_nil => false,
      :allow_blank => false,
    })
    options.update(_options)
    return true if (v.nil? && options[:allow_nil]) || (v.blank? && options[:allow_blank])
    return false if (v.nil? && !options[:allow_nil]) || (v.blank? && !options[:allow_blank])
    if !options[:loose].blank?
      return false if options[:loose].blank? && (/^\d{4}[\-\/]\d{1,2}[\-\/]\d{1,2}( +\d{1,2}\:\d{1,2}(:\d{1,2})?)?$/ !~ v)
    else
      begin
        w1 = DateTime.parse(v)
      rescue # 日付が異常、もしくは日付が存在しない場合
        return false
      else
        return true
      end
    end
  end

  def self.yaml_to_array_for_select_with_additions(before_additions, relation_name, after_additions, options={})
    before_additions + yaml_to_array_for_select(relation_name, options) + after_additions
  end
  
  def self.yaml_to_array_for_select(relation_name, options={})
    yaml = options[:yaml]
    hx = Gw::NameValue.get_cache('yaml', yaml, relation_name)
    unless hx['_base'].nil?
      hx_ind = hx.dup
      hx_base = Gw::NameValue.get_cache('yaml', yaml, hx['_base'])
      hx = hx_base.deep_merge(hx_ind)
      hx.delete '_base'
    end
    ret = hash_to_array_for_select(hx, options)
    options_options_for_select = options.dup
    options_options_for_select.delete [:include_blank]
    return options[:to_s].nil? ? ret : Gw.options_for_select(ret, options[:selected], options_options_for_select)
  end

  def self.hash_to_array_for_select(hx, options={})
    cols = hx['_cols']
    hx.delete('_cols')
    hxa = hx.to_a
    rev = !options[:for_select_by_list].blank? ? true : !options[:rev].blank? # 出力順序 false=> [v,k] true=>[k,v]
    if cols.nil?
      ret = hxa
      sort_by_option = nz(options[:sort_by],(hxa.last.nil? ?
        nil :
        (rev ? 0 : 1)))
    else
      cols = cols.split(':')
      ret = cols.select{|x| !hxa.assoc(x).nil? }.collect{|x| [x, hx[x]]}
      sort_by_option = options[:sort_by]
    end
    ret = ret.collect{|x| [x[1],x[0]]} if !rev
    ret = ret.sort_by{|x| x[sort_by_option]} if !sort_by_option.nil?
    if !options[:include_blank].nil?
      blanker = options[:include_blank].is_a?(Array) ? options[:include_blank] : ['', '---']
      blanker[1], blanker[0] = blanker[0], blanker[1] if !rev
      ret.unshift blanker
    end
    return ret
  end

  def self.svn_str
    ret = ''
    sout = `svn info`
    unless sout.nil?
      hx = sout.split "\n"
      rev = ''
      hx.each do |x|
        xx = x.split ':'
        rev = xx[1].strip if xx[0] == 'Revision' || xx[0] == 'リビジョン'
      end
      ret += " Rev.#{rev}" if !rev.nil? && rev != ''
    end
    return ret
  end

  def self.get_select_index(opts, search, options={})
    value_if_nil = options[:value_if_nil_only]
    value_if_not_found = options[:value_if_not_found]
    if options.has_key? :value_if_nil
      value_if_nil = options[:value_if_nil]
      value_if_not_found = options[:value_if_nil]
    end
    return value_if_nil if search.nil?
    idx = opts.assoc search
    return idx.nil? ? value_if_not_found : idx[1]
  end

  def self.options_for_select(container, selected = nil, options={})

    title_base = options[:title].nil? ? '' : !options[:title].is_a?(Symbol) ? %Q( title="#{options[:title]}") :
      case options[:title]
      when :n0, :n1
        title_flg = options[:title]
      end

    container = container.to_a if Hash === container
    idx = -1
    if !options[:include_blank].nil?
      blanker = options[:include_blank].is_a?(Array) ? options[:include_blank] : ['', '---']
      blanker[1], blanker[0] = blanker[0], blanker[1]
      container.unshift blanker
    end
    options_for_select = container.inject([]) do |options, element|
      idx += 1
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      title = case title_flg
      when :n0
        %Q( title="#{idx}")
      when :n1
        %Q( title="#{idx + 1}")
      else
        title_base
      end
      options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{title}>#{html_escape(text.to_s)}</option>)
    end
    options_for_select.join("\n").html_safe
  end

  def self.is_ar_array?(x)
    return true if x.is_a? WillPaginate::Collection
    return true if x.is_a?(Array) && x.length > 0 && x.last.is_a?(ActiveRecord::Base)

    # for Rails3 convert
    return true if x.is_a?(ActiveRecord::Relation) && x.length > 0 && x.last.is_a?(ActiveRecord::Base)

    return false
  end

  def self.nza(*a)
    raise TypeError if !a.is_a?(Array)
    a.each{|x| return x if !x.blank?}
    return nil
  end

  def self.limit_select
    limits = [
      ['10行' ,10 ],
      ['20行' ,20 ],
      ['30行' ,30 ],
      ['50行' ,50 ],
      ['100行',100],
    ]
    return limits
  end

  def self.month_select
    m_array = [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10],[11,11],[12,12]]
    return m_array
  end

  def self.day_select
    d_array = [
              [1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10],
              [11,11],[12,12],[13,13],[14,14],[15,15],[16,16],[17,17],[18,18],[19,19],[20,20],
              [21,21],[22,22],[23,23],[24,24],[25,25],[26,26],[27,27],[28,28],[29,29],[30,30],[31,31]
              ]
    return d_array
  end

  def self.usage_select
    return [['使用中' , 'u' ],['使用中止' , 's' ]]
  end

  def self.usage_select_sb13
    return [['使用中' , 'u' ],['廃止済み' , 's' ]]
  end


private
  def self.option_text_and_value(option)
    if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:last)
      [option.first, option.last]
    else
      [option, option]
    end
  end

  def self.option_value_selected?(value, selected)
    if selected.respond_to?(:include?) && !selected.is_a?(String)
      selected.include? value
    else
      "#{value}"=="#{selected}"
    end
  end

  def self.html_escape(s)
    s.to_s.gsub(/[&"><]/) { |special| ERB::Util.html_escape(special) }
  end

  class Error < StandardError
  end
  class ApplicationError < Error
  end
  class SystemError < Error
  end
  class ARTransError < Error
  end


  def self.helperx
    HelperX.instance
  end

private
  class HelperX
    include Singleton
    include LinkHelper
    include ActionView::Helpers::UrlHelper # url_for
    include ActionView::Helpers::TagHelper # escape_once
  end
end
