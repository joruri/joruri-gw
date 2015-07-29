class Cms::Lib::Pagination < WillPaginate::LinkRenderer
protected

  def url_options(*params)
    options = super

    uri = @template.url_for(options)
    if uri =~ /\?/
      uri = uri.gsub(/.*\?/, @template.request.env['PATH_INFO'] + '?')
    else
      uri = @template.request.env['PATH_INFO']
    end

    return uri
  end

end
