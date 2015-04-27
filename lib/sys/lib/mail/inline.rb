class Sys::Lib::Mail::Inline
  attr_accessor :seqno
  attr_accessor :content_type
  attr_accessor :text_body
  attr_accessor :html_body
  attr_accessor :alternative
  attr_accessor :attachment
  
  def initialize(attributes = {})
    attributes.each {|name, value| eval("@#{name} = value")}
  end

  def alternative?
    @alternative
  end
  
  def attachment?
    @attachment
  end

end
