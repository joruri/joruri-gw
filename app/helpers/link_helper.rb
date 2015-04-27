module LinkHelper
  def action_menu(type, link = nil, options = {})
    action = params[:action]

    if action =~ /index/
      return '' if [:index, :show, :edit, :destroy].index(type)
    elsif action =~ /(show|destroy)/
      return '' unless [:index, :edit, :destroy].index(type)
    elsif action =~ /(new|create)/
      return '' unless [:index].index(type)
    elsif action =~ /(edit|update)/
      return '' unless [:index, :show].index(type)
    end

    if type == :destroy
      options[:confirm] = '削除してよろしいですか？'
      options[:method]  = :delete
      #options[:remote]  = true
    end

    if link.class == String
      return link_to(type, link, options)
    elsif link.class == Array
      return link_to(link[0], link[1], options)
    else
      return link_to(type, url_for(:action => type), options)
    end
  end

  def link_to(*params)
    labels = {
      :up        => '上へ',
      :index     => '一覧',
      :list      => '一覧',
      :show      => '詳細',
      :new       => '新規作成',
      :edit      => '編集',
      :delete    => '削除',
      :destroy   => '削除',
      :open      => '公開',
      :close     => '非公開',
      :enabale   => '有効化',
      :disable   => '無効化',
      :recognize => '承認',
      :publish   => '公開',
      :close     => '非公開'
    }
    params[0] = labels[params[0]] if labels.key?(params[0])
    if request && request.mobile? && !request.mobile.supports_cookie?
      params[1] = jpmobile_url(params[1])
    end
    options = params[2]

    if options && options[:method] == :delete
      options[:method] = nil

      onclick = "var f = document.createElement('form');" \
        "f.style.display = 'none';" \
        "this.parentNode.appendChild(f);" \
        "f.method = 'POST';" \
        "f.action = this.href;" \
        "var m = document.createElement('input');" \
        "m.setAttribute('type', 'hidden');" \
        "m.setAttribute('name', '_method');" \
        "m.setAttribute('value', 'delete');" \
        "f.appendChild(m);" \
        "var s = document.createElement('input');" \
        "s.setAttribute('type', 'hidden');" \
        "s.setAttribute('name', 'authenticity_token');" \
        "s.setAttribute('value', '#{form_authenticity_token}');" \
        "f.appendChild(s);" \
        "f.submit();"

      if options[:confirm]
        onclick = "if (confirm('#{options[:confirm]}')) {#{onclick}};"
        #options[:confirm] = nil
        options.delete(:confirm)
      end
      options[:onclick] = onclick + "return false;"
    end
    if options && options[:confirm]
      opt_confirm = options[:confirm]
      options.delete(:confirm)
      if options[:data]
        opt_data = options[:data]
        opt_data[:confirm] = opt_confirm
        options[:data] = opt_data
      else
        options[:data] = {:confirm => opt_confirm}
      end
    end

    super(*params)
  end

  def jpmobile_session_key
    key = request.session_options[:key]
    key = "_session_id" if key.blank?
    return key
  end

  def jpmobile_session_id
    request.session_options[:id] rescue session.session_id
  end

  def jpmobile_url(url)
    begin
      url_parse = URI.parse(url)
      skey = jpmobile_session_key
      sid  = jpmobile_session_id
      if url_parse.query
        url_parse.query += "&#{skey}=#{sid}"
      else
        url_parse.query = "#{skey}=#{sid}"
      end
      session_url = url_parse.to_s
    rescue URI::InvalidURIError
      session_url = url
    end
    return session_url
  end

  ## E-mail to entity
  def email_to(addr, text = nil)
    return '' if addr.blank?
    text ||= addr
    addr.gsub!(/@/, '&#64;')
    addr.gsub!(/a/, '&#97;')
    text.gsub!(/@/, '&#64;')
    text.gsub!(/a/, '&#97;')
    mail_to(text, addr)
  end

  ## Tel
  def tel_to(tel, text = nil)
    text ||= tel
    return tel if tel.to_s !~ /^([\(]?)([0-9]+)([-\(\)]?)([0-9]+)([-\)]?)([0-9]+$)/
    link_to text, "tel:#{tel}"
  end

  def link_to_with_external_check(caption, uri, options={})
    options_wrk = options.dup
    options_wrk['class'] = 'ext' if link_external?(uri)
    return link_to(caption, uri, options_wrk)
  end

  def link_external?(uri)
    require 'uri'
    return false if uri.index('://').nil?
    parsed = URI.parse(uri)
    case parsed.class.to_s
    when 'URI::Generic'
      return false
    when 'URI::HTTP'
      rails_env = ENV['RAILS_ENV']
      rails_env = 'development' if rails_env == 'test'
      trans_hash_raw = YAML.load_file('config/core.yml')
      return ( parsed.host != trans_hash_raw[rails_env]['uri'] ) rescue raise 'site.yml の設定を見直してください。'
    else
      return true
    end
  end

  def link_to_list(item, caption = '展開', options={})
    link_to_with_external_check caption, url_for(:action => :index, :parent => item)
  end

  alias :link_to_explore :link_to_list

  def link_to_show(item, caption = '詳細', options={})
    caption = nz(caption, '詳細')

    uri = url_for(:action => :show, :id => item)
    link_to_with_external_check caption, uri, options
  end

  def link_to_edit(item, caption = '編集', options={})
    caption = nz(caption, '編集')

    uri = url_for(:action => :edit, :id => item)
    opt = options.dup
    uri = "#{uri}?#{opt[:qs]}" if !opt[:qs].blank?
    opt.delete :qs
    link_to_with_external_check caption, uri, opt
  end

  def link_to_destroy(item, caption = '削除', options={})
    caption = nz(caption, '削除')
    opt = HashWithIndifferentAccess.new(options)
    opt[:confirm] = nz(options[:confirm], '削除してよろしいですか？')
    opt[:method] = :delete

    uri = url_for(:action => :destroy, :id => item)
    uri = "#{uri}?#{opt[:qs]}" if !opt[:qs].blank?
    opt.delete :qs
    link_to_with_external_check caption, uri, opt
  end

  def link_to_id(action, id, caption, base_uri)
      link_to_with_external_check caption, url_for("#{base_uri}#{id}/#{action}")
  end

  def sort_link(title, sort_keys, path_index, field_name, other_query_string='')
    other_query_string = nz(other_query_string, '')
    ret = sort_keys == "#{field_name}%20asc" ? '▲' : link_to('▲', path_index + "?sort_keys=" + "#{field_name}%20asc" + (other_query_string=='' ? '' : '&amp;' + other_query_string ))
    ret += ' '
    ret += sort_keys == "#{field_name}%20desc" ? '▼' : link_to('▼', path_index + "?sort_keys=" + "#{field_name}%20desc" + (other_query_string=='' ? '' : '&amp;' + other_query_string ))
#    ret += "<br />"
    ret += ' '
    ret += title
    return ret
  end

  def link_with_sort_keys(title, url_options, field_name)
    ret = params[:sort_keys] == "#{field_name} asc" ? '▲' : link_to('▲', url_options.merge(sort_keys: "#{field_name} asc"))
    ret += ' '
    ret += params[:sort_keys] == "#{field_name} desc" ? '▼' : link_to('▼', url_options.merge(sort_keys: "#{field_name} desc"))
    ret += "<br />".html_safe
    ret += ' '
    ret += title
    ret.html_safe
  end
end
