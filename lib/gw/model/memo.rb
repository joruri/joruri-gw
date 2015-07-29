# encoding: utf-8
require 'gwlib'
include GwLib

module Gw::Model::Memo
  
  def self.remind(uid = nil)
    item = Gw::Memo.new
    d = Date.today

    setting = Gw::Model::Schedule.get_settings 'memos',{}
    return {} if setting['read_memos_display'].to_i == 0 && setting['unread_memos_display'].to_i == 0

    items = item.find(:all, :order => 'created_at',
      :conditions => remind_cond(d, uid, setting), :joins=>'left join gw_memo_users on gw_memos.id = gw_memo_users.schedule_id',
      :select=>'gw_memos.*')
    return items.collect{|x|
      {
      :date_str => x.created_at.nil? ? '期限なし' : x.created_at.strftime("%m/%d %H:%M"),
      :cls => '連絡メモ',
      :title => %Q(<a href="/gw/memos/#{x.id}">#{x.title}　[#{System::User.get(x.uid).display_name}]</a>),
      :date_d => x.created_at
      }
    }
  end

  def self.remind_xml(uid  , xml_data )
    #dump ["Gw::Tool::Reminder.checker_api　memos_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    return xml_data if uid.blank?
    return xml_data if xml_data.blank?
    item = Gw::Memo.new
    d = Date.today
    setting = Gw::Model::Schedule.get_settings 'memos',{:uid=>"#{uid}"}
    return xml_data if setting['read_memos_display'].to_i == 0 && setting['unread_memos_display'].to_i == 0
    setting[:p]=2
    memo_cond   = Gw::Model::Memo.remind_cond(d, uid, setting)
    memo_join = 'left join gw_memo_users on gw_memos.id = gw_memo_users.schedule_id'
    items = item.find(:all, :order => 'created_at',:conditions => memo_cond , :joins=>memo_join,:select=>'gw_memos.*')
    if items.blank?
      return xml_data
    end
    items.each do |memo|
      user  = System::User.find_by_id(memo.uid)
      next if user.blank?
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{memo.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gw/memos/#{memo.id}"/>)
      xml_data  << %Q(<updated>#{memo.created_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="memo">連絡メモ</category>)
      xml_data  << %Q(<title>#{memo.title}</title>)
      xml_data  << %Q(<author><name>#{user.display_name}</name></author>)
      xml_data  << %Q(</entry>)
    end
    #dump ['memos_xml' ,xml_data]
    return xml_data
  end

  def self.remind_cond(d, _uid = nil, options={})
    ret = "#{recv_cond(_uid,options)}"
    tmp = ''
    if !options['read_memos_display'].blank? && options['read_memos_display'].to_i != 0
      read_d = d - options['read_memos_display'].to_i + 1
      tmp += " ( gw_memos.is_finished = 1 and gw_memos.created_at > '#{read_d.strftime('%Y-%m-%d 0:0:0')}' ) "
    end
    if !options['unread_memos_display'].blank? && options['unread_memos_display'].to_i != 0
      unread_d = d - options['unread_memos_display'].to_i + 1
      tmp += " or " if tmp != ""
      tmp += " ( coalesce(gw_memos.is_finished, 0) != 1 and gw_memos.created_at > '#{unread_d.strftime('%Y-%m-%d 0:0:0')}' ) "
    end
    ret += " and  ( " + tmp + " ) " if (tmp != '')
    "(#{ret})"
  end

  def self.send_cond(_uid=nil)
    Gw::Memo.cond(_uid)
  end

  def self.recv_cond(_uid=nil,options=nil)
    if options.blank?
      uid = nz(_uid, Core.user.id)
    else
      if options.has_key?(:p)
        uid = _uid
      else
        uid = nz(_uid, Core.user.id)
      end
    end
    "(gw_memo_users.class_id = 1 and gw_memo_users.uid = #{uid})"
  end

  def self.date_cond(d)
    "(gw_memos.created_at > '#{(d-2).strftime('%Y-%m-%d 0:0:0')}' and gw_memos.created_at < '#{(d+7).strftime('%Y-%m-%d 0:0:0')}' )"
  end

  def self.date_cond_main(d)
    "(gw_memos.created_at < '#{(d+7).strftime('%Y-%m-%d 0:0:0')}')"
  end

end
