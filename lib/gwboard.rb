#encoding:utf-8
class Gwboard
  
  def self.add_reminder_circular(uid, title, body, options={})
    fr_u = System::User.find(:first, :conditions=>"id=#{uid}") rescue Site.user
    fr_u = Site.user if fr_u.blank?
    begin
      Gw::Database.transaction do
        memo = {
          :state=>1,
          :class_id=>options[:parent_id],
          :uid=>fr_u.id,
          :gid=>options[:doc_id],
          :title=>title,
          :ed_at=>nz(options[:ed_at],Gw.datetime_str(Time.now)),
          :is_finished=>options[:is_finished],
          :body=>body
        }
        item = Gw::Circular.new(memo)
        item.save!
      end
      return true
    rescue => e
      case e.class.to_s
      when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
      else
        raise e
      end
      return false
    end
  end

  def self.fyear_to_namejp_ymd(date = nil , options={} )
    return nil if date.to_s.blank?

    dates = Gw.date_str(date).split('-')
    fyears = Gw::YearMarkJp.convert_ytoj(dates,'3','1')
    show_str = ''
    if fyears.blank?
    else
      show_str = fyears[2] + '年' + sprintf("%02d",dates[1].to_i) + '月'+ sprintf("%02d",dates[2].to_i) + '日'
    end
    return show_str
  end

  def self.fyear_to_namejp_ym(date = nil , options={} )
    return nil if date.to_s.blank?

    dates = Gw.date_str(date).split('-')
    fyears = Gw::YearMarkJp.convert_ytoj(dates,'3','1')
    show_str = ''
    if fyears.blank?
    else
      show_str = fyears[2] + '年' + sprintf("%02d",dates[1].to_i) + '月'
    end
    return show_str
  end

  def self.fyear_to_namejp_ymd_old(date = nil)
    return nil if date.to_s.blank?
    dates = Gw.date_str(date).split('-')
    dates2 = Gw.date_str(date).split('-')
    if dates[1].to_i < 4
      dates2[1]=4
      date2 = Time.local(dates2[0],dates2[1],dates2[2],'00','00','00')
    else
      date2 = date
    end
    fyears = Gw::YearFiscalJp.get_record(date2)
    show_str = ''
    if fyears.blank?
    else
      show_str = fyears.namejp + '年' + sprintf("%02d",dates[1].to_i) + '月'+ sprintf("%02d",dates[2].to_i) + '日'
    end
    return show_str
  end

  def self.fyear_to_namejp_ym_old(date = nil)
    return nil if date.to_s.blank?
    dates = Gw.date_str(date).split('-')
    dates2 = Gw.date_str(date).split('-')
    if dates[1].to_i < 4
      dates2[1]=4
      date2 = Time.local(dates2[0],dates2[1],dates2[2],'00','00','00')
    else
      date2 = date
    end
    fyears = Gw::YearFiscalJp.get_record(date2)
    show_str = ''
    if fyears.blank?
    else
      show_str = fyears.namejp + '年' + sprintf("%02d",dates[1].to_i) + '月'
    end
    return show_str
  end
end