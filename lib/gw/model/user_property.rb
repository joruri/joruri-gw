# encoding: utf-8
module Gw::Model::UserProperty
  def self.get(property_name, options={})

    if options[:class_id].blank? || options[:class_id] == 1
      u = options[:uid].blank? ? Core.user : Gw::Model::Schedule.get_user(options[:uid])
      uid = u.id
      cond = {:uid=>uid, :name=>property_name, :class_id => 1}
    elsif options[:class_id] == 2

    elsif options[:class_id] == 3
      cond = {:name=>property_name, :class_id => 3}
    end

    if !u.blank? || options[:class_id] == 3
      hx = Gw::UserProperty.find(:first, :conditions => cond)
      key = property_name.pluralize
      return nil if hx.nil?
      case hx['type_name']
      when 'yaml'
        h_options = YAML.load(hx['options'])
      when 'json'
        h_options = JsonParser.new.parse(hx['options'])
      when 'xml'
        h_options = Hash.from_xml(hx['options'])
      else
        raise TypeError
        h_options = {:error => 'unknown type.'}
      end

      return h_options
    else
      raise TypeError, "Not Logged in."
    end
  end

  def self.new(hx)
    GW::UserProperty.new(hx)
  end

  def self.save(property_name, h_save, options={})
    errors = []
    key = property_name.pluralize
    trans = Gw.yaml_to_array_for_select("gw_#{key}_settings_ind")
    trans_raw = Gw::NameValue.get('yaml', nil, "gw_#{key}_settings_ind")
    options[:nodefault] = 1 if key == 'feeds'
    default = Gw::NameValue.get('yaml', nil, "gw_#{key}_settings_system_default") if options[:nodefault].nil?
    item = h_save[key]
    item = h_save[key]['pref_soumu'] if key == 'ssos'
    case key
    when 'feeds'
      trans = Gw.yaml_to_array_for_select('gw_rssreader')
      feeds = item
      if feeds.nil?
        errors.push ['feeds', 'データが異常です']
      else
        feeds.each do |feed|
          'uri:title:max'.split(':').each do |x|
            fld = trans.rassoc(x)[0] rescue x
            errors.push [x, "#{fld}を入力してください。"] if feed[x].blank?
          end
        end
      end
    when 'schedules'
      if options[:class_id] == 1
        trans.each do |x|
          fld = x[1]
          fld_disp = x[0]
          errors.push [fld, "#{fld_disp}は必ず入力してください。"] if item[fld].blank?
        end
  
        %w(week_view_piecehead_format week_view_dayhead_format month_view_piecehead_format month_view_dayhead_format).each do |x|
          fld = trans.rassoc(x)[0] rescue x
          if !item[x].blank?
            err = Gw.date_format(item[x], Time.now) rescue nil
            errors.push [x, "#{fld}が異常です。"] if err.nil?
          end
        end
  
        %w(month_view_leftest_weekday).each do |fld|
          fld_disp = trans.rassoc(fld)[0] rescue fld
          x = item[fld]
  
          if !x.nil?
            if Gw.int?(x)
              if !((0..6).include?(x.to_i))
                errors.push [fld, "#{fld_disp}は 0～6 の整数でなければいけません。"]
              end
            else
              errors.push [fld, "#{fld_disp}は 0～6 の整数でなければいけません。"]
            end
          end
        end
  
        %w(header_each).each do |fld|
          fld_disp = trans.rassoc(fld)[0] rescue fld
          x = item[fld]
          if !x.blank? && (!Gw.int?(x) || x.to_i < 0 )
            errors.push [fld, "#{fld_disp}は 0 以上の数値でなければいけません。"]
          end
        end
      end
    when 'ssos'
      trans.each do |x|
        fld = x[1]
        fld_disp = x[0]

      end

      itm1 = item[trans[0][1]]
      itm2 = item[trans[1][1]]
      errors.push [trans[0][1], "#{trans[0][0]}は必ず入力してください。"] if itm1.blank? && !itm2.blank?
      errors.push [trans[1][1], "#{trans[1][0]}は必ず入力してください。"] if !itm1.blank? && itm2.blank?
    when 'mobiles'

      if item['ktrans'].to_s=='2'

        ret = 0
      else
        trans.each do |x|
          fld = x[1]
          fld_disp = x[0]
          errors.push [fld, "#{fld_disp}は必ず入力してください。"] if item[fld].blank?
          ret = 1
        end
        %w(kmail).each do |fld|
          fld_disp = trans.rassoc(fld)[0] rescue fld
          x = item[fld_disp]
          case Gw.is_valid_email_address?(item[fld])
          when 0
            errors.push [fld, "#{fld_disp}は正しいEメールアドレスではありません。"]
            ret = 1
          when 2
            ret = 2
          else
            ret = 0
          end
        end
      end

    when 'memos'
    when 'todos'
    when 'portals'
    when 'rssids'
    when 'blogparts'
    else
      raise TypeError, "未知の型です(#{key})"
    end
    return errors if errors.length > 0
    trans.each do |x|
      item.delete x[1] if item[x[1]] == default[x[1]] if options[:nodefault].nil? # default と同じなら保存しない
    end

    if options[:class_id].blank? || options[:class_id] == 1
      uid = Core.user.id
      hx = Gw::UserProperty.find(:first, :conditions => {:uid=>uid, :name=>property_name, :class_id => 1})
      hx = Gw::UserProperty.new({:class_id=>1, :uid=>uid.to_s, :name=>property_name, :type_name=>'json', :options => ''}) if hx.nil?
    elsif options[:class_id] == 2

    elsif options[:class_id] == 3
      uid = Core.user.id
      hx = Gw::UserProperty.find(:first, :conditions => {:name=>property_name, :class_id => 3})
      hx = Gw::UserProperty.new({:class_id=>3, :uid=>uid.to_s, :name=>property_name, :type_name=>'json', :options => ''}) if hx.nil?
    end

    case hx['type_name']
    when 'yaml'
      s_to = h_save.to_yaml
    when 'json'
      s_to = h_save.to_json
    when 'xml'
      s_to = h_save.to_xml
    else
      raise TypeError
      return {:error => 'unknown type.'}
    end

    hx.options = s_to
    if key=='mobiles'
      if ret == 1
      else
        hx.save
      end
      return ret
    else
      return hx.save
    end
  end

end