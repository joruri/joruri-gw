# encoding:utf-8
class Gw::MemoMobile < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def self.is_email_mobile?(email = nil)
    return false if email.blank? || !email.include?("@")
    domain = email.match(/@/).post_match

    items = Array.new
    items = self.find(:all).select{|x| domain.include?(x.domain)}

    if items.length > 0
      return true
    else
      return false
    end
  end

  def self.get_class_name(uid = Site.user.id)
    property = Gw::UserProperty.new.find(:first, :conditions=>["uid = ? and class_id = 1 and name = 'mobile'", uid])
    if !property.blank? && property.is_email_mobile?
      mobile_class = 'mobileOn'
    else
      mobile_class = 'mobileOff'
    end
    return mobile_class
  end

  def self.memos_users_view(items, options = {})
    caption = nz(options[:caption])
    include_table_tag = true if options[:include_table_tag].nil?

    ret = ''
    ret += '<table class="show">' if include_table_tag
    ret += %Q(<tr><th colspan="2">#{caption}</th></tr>) if caption
    items.each do |x|
      begin
        case x.class_id
        when 0
          th = 'すべて'
          td = ''
        when 1
          th = 'ユーザ'
          mobile_class = Gw::MemoMobile.get_class_name(x.uid)
          td = "<span class=\"#{mobile_class}\">" + System::User.find(:first, :conditions => "id=#{x.uid}").display_name + "</span>"
        when 2
          th = 'グループ'
          td = '<span class="mobileOff">' + System::Group.find(:first, :conditions => "id=#{x.uid}").name + '</span>'
        end
        ret += "<tr><th>#{th}</th><td>#{td}</td></tr>"
      rescue
      end
    end
    ret += '</table>' if include_table_tag
    ret
  end
end
