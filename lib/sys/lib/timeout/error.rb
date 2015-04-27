class Sys::Lib::Timeout::Error < Exception
  
  attr_accessor :second
  
  def initialize(sec = nil)
    @second = sec
    super("Timeout!!(#{sec} sec)")
  end
  
end