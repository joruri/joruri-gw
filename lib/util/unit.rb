# encoding: utf-8
class Util::Unit
  def self.eng_unit(size, postfix = "B")
    return '' unless size.to_s =~ /^[0-9]+$/
    if size >= 10**9
      _kilo = 3
      _unit = 'G'
    elsif size >= 10**6
      _kilo = 2
      _unit = 'M'
    elsif size >= 10**3
      _kilo = 1
      _unit = 'K'
    else
      _kilo = 0
      _unit = ''
    end
    
    if _kilo > 0
      size = (size.to_f / (1024**_kilo)).to_s + '000'
      _keta = size.index('.')
      if _keta == 3
        size = size.slice(0, 3)
      else
        size = size.to_f * (10**(3-_keta))
        size = size.to_f.ceil.to_f / (10**(3-_keta))
      end
    end
    
    return "#{size}#{_unit}#{postfix}"
  end
end