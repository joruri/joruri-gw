# encoding: utf-8
require 'nkf'
class NKFUtil
  
  def self.output_option(charset)
    opt = nil
    case charset.downcase
    when 'iso-2022-jp'
      opt = '-j'
    when 'euc-jp'
      opt = '-e'
    when 'eucjp-ms'
      opt = '--oc=eucJP-ms'
    when 'cp51932'
      opt = '--oc=CP51932'
    when 'shift_jis'
      opt = '-s -x'
    when 'windows-31j'
      opt = '--oc=CP932'
    when 'utf-8'
      opt = '-w -x'
    end
    opt
  end
  
  def self.input_option(charset)
    opt = nil
    case charset.downcase
    when 'iso-2022-jp'
      opt = '-J'
    when 'euc-jp'
      opt = '-E'
    when 'shift_jis'
      opt = '-S'
    when 'utf-8'
      opt = '-W'
    end
    opt    
  end
end
