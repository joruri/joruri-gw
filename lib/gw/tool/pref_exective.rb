# encoding: utf-8
class Gw::Tool::PrefExective

  def self.accesslog_save(ip_addr=nil)

  end

  def self.member_xml_output

    model = Gw::PrefAssemblyMember.new
    cond  = "deleted_at IS NULL"
    order = "g_order, u_order"

    items = model.find(:all ,:conditions => cond,:order => order )
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.feed('xmlns' => 'http://www.w3.org/2005/Atom'){
      xml.id("tag:2011:/api/pref/exectives")
      xml.title("議員在席表示")
      xml.updated(Time.now.strftime('%Y-%m-%d %H:%M:%S'))
      if items.size.blank?
        xml.entry do
          xml.member("議員情報無し")
        end
      else
        items.each do |m|
          xml.entry do
            xml.id(m.id)
            xml.category(m.g_order)
            xml.generator(m.u_order)
            xml.title(m.g_name)

            xml.author do
              xml.lname(m.u_lname)
              xml.fname(m.u_name)
            end

            xml.summary(m.state)
            xml.updated(m.updated_at.strftime('%Y-%m-%d %H:%M:%S')) unless m.updated_at.blank?
          end
        end
      end
    }

    return xml_obj
  end

  def self.leader_xml_output(mode=nil)

    model = Gw::PrefExecutive.new
    cond  = "deleted_at IS NULL"
    if mode == 2 then
      cond += " AND is_governor_view  = 1"
    else
      cond += " AND is_other_view  = 1"
    end
    order = "u_order"

    items = model.find(:all ,:conditions => cond,:order => order )
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.feed('xmlns' => 'http://www.w3.org/2005/Atom'){
      xml.id("tag:2011:/api/pref/exectives")
      xml.title("全庁幹部在席表示")
      xml.updated(Time.now.strftime('%Y-%m-%d %H:%M:%S'))
      if items.size.blank?
        xml.entry do
          xml.member("幹部情報無し")
        end
      else
        items.each do |m|
          xml.entry do
            xml.id(m.id)
            xml.category(m.u_order)

            xml.title(m.title)
            xml.g_name(m.g_name)

            xml.author do
              xml.lname(m.u_lname)
              xml.fname(m.u_name)
            end

            xml.summary(m.state)
            xml.updated(m.updated_at.strftime('%Y-%m-%d %H:%M:%S')) unless m.updated_at.blank?
          end
        end
      end
    }

    return xml_obj
  end

  def self.secretary_xml_output(mode=nil)
    model = Gw::PrefDirector.new
	if mode == 2
	    cond  = "deleted_at IS NULL AND is_governor_view = 1 "
	else
	    cond  = "deleted_at IS NULL AND g_code ='A50000' "
	end
    order = "u_order"
    items = model.find(:all ,:conditions => cond,:order => order )
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.feed('xmlns' => 'http://www.w3.org/2005/Atom'){
      xml.id("tag:2011:/api/pref/exectives")
      if mode == 2
        xml.title("全庁幹部在席表示　３役")
      else
        xml.title("全庁幹部在席表示　議会事務局")
      end
      xml.updated(Time.now.strftime('%Y-%m-%d %H:%M:%S'))
      if items.size.blank?
        xml.entry do
          xml.member("幹部情報無し")
        end
      else
        items.each do |m|
          xml.entry do
            xml.id(m.id)
            xml.category(m.u_order)

			if mode == 2
				official_title = m.title
			else
	            if m.title == "局長"
	              official_title = "議会事務局長"
	            elsif m.title == "次長"
	              official_title = "事務局次長"
	            else
	              official_title = m.title
	            end
			end
            xml.title(official_title)
            xml.g_name(m.g_name)

            xml.author do
              xml.lname(m.u_lname)
              xml.fname(m.u_name)
            end

            xml.summary(m.state)
            xml.updated(m.updated_at.strftime('%Y-%m-%d %H:%M:%S')) unless m.updated_at.blank?
          end
        end
      end
    }

    return xml_obj
  end

  def self.assembly_access(state=nil,id=nil)
    return "" if (state.blank? || id.blank?)
    result = "false"
    member = Gw::PrefAssemblyMember.find_by_id(id)
    unless member.blank?
      member.state = state
      if member.save(:validate=>false)
        result = "true"
      end
    end
    xm = Builder::XmlMarkup.new :indent => 2
    xm.instruct!(:xml, :encoding => "UTF-8")
    xml = xm.xml_data {
      xm.entry do
        xm.result(result)
      end
      }
    return xml
  end

  def self.exective_access(state=nil,id=nil)
    dump state
    dump id
    return "" if (state.blank? || id.blank?)
    result = "false"
    member = Gw::PrefExecutive.find_by_id(id)
    unless member.blank?
      member.state = state
      if member.save(:validate=>false)
        result = "true"
      end
    end
    xm = Builder::XmlMarkup.new :indent => 2
    xm.instruct!(:xml, :encoding => "UTF-8")
    xml = xm.xml_data {
      xm.entry do
        xm.result(result)
      end
      }
    return xml
  end

end
