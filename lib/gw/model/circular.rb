# encoding: utf-8
module Gw::Model::Circular

  def self.remind(uid = Site.user.id)
    item = Gw::Circular.new
    remind_cond = "state=1 AND uid = #{uid} AND ed_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    items = item.find(:all, :conditions=>remind_cond ,  :order => 'ed_at', :select=>'gw_circulars.*')
    return items.collect{|x|
      if x.title =~ /\[/
         w_title = x.title
       else
         w_title = x.title.gsub('</a>','')
         docs = Gwcircular::Doc.find_by_id(x.class_id)
         if docs.blank?
           author_str  = nil
         else
           author_str  = docs.creater.to_s + '('+ docs.creater_id.to_s + ')'
         end
         w_title = w_title.to_s + " [#{author_str}]</a>"
       end
      {
      :date_str => x.created_at.nil? ? '' : x.created_at.strftime("%m/%d %H:%M"),
      :cls => '回覧板',
      :title => w_title,
      :date_d => x.created_at
      }
    }
  end

  def self.remind_xml(uid  , xml_data = nil)
    #dump ["Gw::Tool::Reminder.checker_api　circular_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    return xml_data if uid.blank?
    return xml_data if xml_data.blank?
    item = Gw::Circular.new
    remind_cond = "state=1 AND uid = #{uid} AND ed_at > '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    items = item.find(:all, :conditions=>remind_cond ,  :order => 'ed_at', :select=>'gw_circulars.*')
    if items.blank?
      return xml_data
    end
    items.each do |circular|
      author = circular.title.scan(/(\S+)\[(\S+)\](\S+)/)
      if author.size==0
        docs = Gwcircular::Doc.find_by_id(circular.class_id)
        if docs.blank?
          author_str  = nil
        else
          author_str  = docs.creater.to_s + '('+ docs.creater_id.to_s + ')'
        end
      else
        author_str  = author[0][1]
      end
      title = circular.title
      title_a = title.scan(/(\S+)>([\S|\s]+)\[(\S+)\]<(\S+)/)
      if title_a.size==0
        title_b = title.scan(/(\S+)>([\S|\s]+)<\/a>/)
        if title_b.size==0
          title_str = nil
        else
          title_str = title_b[0][1]
        end
      else
        title_str = title_a[0][1]
      end
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{circular.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gwcircular"/>)
      xml_data  << %Q(<updated>#{circular.created_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="circular">回覧板</category>)
      xml_data  << %Q(<title>#{title_str}</title>)
      xml_data  << %Q(<author><name>#{author_str}</name></author>)
      xml_data  << %Q(</entry>)
    end
    #dump ['monitor_xml' ,xml_data]
    return xml_data
  end

end
