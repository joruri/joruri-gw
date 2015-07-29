# encoding: utf-8
class Cache
  def self.load(c_key)
    begin
      value = Rails.cache.read(c_key)
      if value.blank?
        value = yield
        Rails.cache.write(c_key, value, :expires_in => 3600)
      else
#        Rails.logger.debug('CACHE HIT:' + c_key)
      end
    rescue => e
      value = yield
#      dump 'CACHE ERROR:' + c_key
#      dump e.backtrace.join("\n")
    end
    return value
  end
end
