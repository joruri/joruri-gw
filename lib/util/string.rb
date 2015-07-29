# encoding: utf-8
module Util::String
  def self.search_platform_dependent_characters(str)
    regex = "[" +
      "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳" +
      "ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ㍉㌔㌢㍍㌘㌧㌃㌶㍑㍗" +
      "㌍㌦㌣㌫㍊㌻㎜㎝㎞㎎㎏㏄㎡㍻〝〟№㏍℡㊤" +
      "㊥㊦㊧㊨㈱㈲㈹㍾㍽㍼㍻©®㈷㈰㈪㈫㈬㈭㈮㈯" +
      "㊗㊐㊊㊋㊌㊍㊎㊏㋀㋁㋂㋃㋄㋅㋆㋇㋈㋉㋊㋋" +
      "㏠㏡㏢㏣㏤㏥㏦㏧㏨㏩㏪㏫㏬㏭㏮㏯㏰㏱㏲㏳" +
      "㏴㏵㏶㏷㏸㏹㏺㏻㏼㏽㏾↔↕↖↗↘↙⇒⇔⇐⇑⇓⇕⇖⇗⇘⇙" +
      "㋐㋑㋒㋓㋔㋕㋖㋗㋘㋙㊑㊒㊓㊔㊕㊟㊚㊛㊜㊣" +
      "㊡㊢㊫㊬㊭㊮㊯㊰㊞㊖㊩㊝㊘㊙㊪㈳㈴㈵㈶㈸" +
      "㈺㈻㈼㈽㈾㈿►☺◄☻‼㎀㎁㎂㎃㎄㎈㎉㎊㎋㎌㎍" +
      "㎑㎒㎓ⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹ〠♠♣♥♤♧♡￤＇＂" +
      "]"
    
    chars = []
    if str =~ /#{regex}/
      str.scan(/#{regex}/).each do |c|
        chars << c
      end
    end
    
    chars.size == 0 ? nil : chars.uniq.join('')
  end
  
  def self.text_to_html(text)
    rslt = ''
    text.each_line do |line|
      line.chomp!
      line.gsub!(/&/, '&amp;')
      line.gsub!(/</, '&lt;')
      line.gsub!(/>/, '&gt;')
      line.gsub!(/(\s+)\s/) do |m|
        '&nbsp;' * m.length
      end
      #line << '&nbsp;' if line.blank?
      rslt << %Q(<p style="margin:0px; padding:0px;">#{line}</p>\n)
    end
    rslt
  end
  
end