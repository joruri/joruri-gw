module Gw::Model::Plus_update
  def self.remind(uid = nil)

    # リマインダー表示
    model = Gw::PlusUpdate.new
    @date, @msg = Gw::Property::PlusUpdate.where(uid: Core.user.id).first_or_new.limit_date_and_msg
    cond = ["project_users_json LIKE ? and state= ? and doc_updated_at >= ?",%Q(%"#{Core.user.code}"%), "enabled", @date]
    items = model.find(:all, :order => 'doc_updated_at ASC',
      :conditions => cond)

    ret = []
    code = {}

    items.each do |item|
      if code.blank?
        code[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
      else
        if code[item.project_code.to_sym]
          project_params = code[item.project_code.to_sym]
          code[item.project_code.to_sym] = [project_params[0] + 1, item.project_code, item.title, item.doc_updated_at,item.id ]
        else
          code[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
        end
      end
    end
    code.each do |key, value|
      ret << {
        :date_str => value[3].blank? ? "" : value[3].strftime("%m/%d %H:%M"),
        :cls => 'JoruriPlus+',
        :title => %Q(<a href="/gw/plus_update_settings/#{value[4]}/to_project" target="_blank">#{value[2]}に#{value[0]}件の更新があります。</a>),
        :date_d => value[3]
      }
    end
    return ret
  end

  def self.remind_xml(user  , xml_data = nil)
    return xml_data if xml_data.blank?
    remind_items = nil
    unless user.blank?
      uid = user.id
      ucode = user.code
      dump ["Gw::Tool::Reminder.checker_api　plus_update_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
      model = Gw::PlusUpdate.new
      @date, @msg = Gw::Property::PlusUpdate.where(uid: uid).first_or_new.limit_date_and_msg
      cond = ["project_users_json LIKE ? and state= ? and doc_updated_at >= ?",%Q(%"#{user.code}"%), "enabled", @date]
      remind_items = model.find(:all, :order => 'doc_updated_at ASC',
        :conditions => cond)
    end
    project_data = {}
    remind_items.each do |item|
      if project_data.blank?
        project_data[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
      else
        if project_data[item.project_code.to_sym]
          project_params = project_data[item.project_code.to_sym]
          project_data[item.project_code.to_sym] = [project_params[0] + 1, item.project_code, item.title, item.doc_updated_at ,item.id]
        else
          project_data[item.project_code.to_sym] = [1, item.project_code, item.title, item.doc_updated_at,item.id]
        end
      end
    end unless remind_items.blank?
    project_data.each do |key, value|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{value[4]}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gw/plus_update_settings/#{value[4]}/to_project"/>)
      xml_data  << %Q(<updated>#{value[3].strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="plusUpdate">JoruriPlus+</category>)
      xml_data  << %Q(<title>#{value[2]}に#{value[0]}件の更新があります。</title>)
      xml_data  << %Q(<author><name>　</name></author>)
      xml_data  << %Q(</entry>)
    end unless project_data.blank?
#    dump ['monitor_xml' ,xml_data]

    return xml_data
  end


end
