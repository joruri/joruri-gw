class Util::Http::Request
  def self.send(uri, options = {})
    require 'open-uri'
    require "resolv-replace"
    require 'timeout'

    limit    = options[:timeout] || 30
    status   = nil
    body     = ''
    
    settings = { :proxy => Core.proxy }
    
    begin
      timeout(limit) do
        open(uri, settings) do |f|
          status = f.status[0].to_i
          f.each_line {|line| body += line}
        end
      end
    rescue TimeoutError
      status = 404
      #TimeoutError
    rescue
      status = 404
    end
    
    return Util::Http::Response.new({:status => status, :body => body})
  end
end