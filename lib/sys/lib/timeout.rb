class Sys::Lib::Timeout
  
  attr_accessor :second
  
  def initialize(timeout = nil)
    @second = timeout
    @start_time = Time.now
  end
  
  def check
    return unless @second
    sec = (Time.now - @start_time).floor
    raise Sys::Lib::Timeout::Error.new(sec) if sec > @second
  end
end