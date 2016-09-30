class Gwmonitor::Script::Annual

  def self.renew(start_date = nil)
    if start_date.blank?
      return false
    else
      @start_date = start_date
    end
    p "照会・回答年次切替所属情報更新 開始:#{Time.now}."
    renew_controls_section_code
    renew_docs_section_code
    p "照会・回答年次切替所属情報更新 終了:#{Time.now}."
  end

  def self.renew_controls_section_code
    p "renew_controls_section_code 開始:#{Time.now}."

    #sql  = 'SELECT section_code FROM gwmonitor_controls GROUP BY section_code ORDER BY section_code'
    #controls = Gwmonitor::Control.find_by_sql(sql)
    controls = Gwmonitor::Control.group(:section_code)
    for control in controls
      #group = Gwboard::RenewalGroup.find_by_present_group_code(control.section_code,start_date)
      group = Gwboard::RenewalGroup.where("present_group_code = ? and start_date = ?", control.section_code,@start_date).first
      next if group.blank?

      update_fields="section_code='#{group.incoming_group_code}', section_name='#{group.incoming_group_code}#{group.incoming_group_name}'"
      sql_where = "section_code='#{control.section_code}'"
      Gwmonitor::Control.where(:section_code => control.section_code).update_all(:section_code => group.incoming_group_code, :section_name => %Q(#{group.incoming_group_code}#{group.incoming_group_name}))
      p %Q[#{control.id}, #{control.section_code}, "#{update_fields}", #{Time.now}.]

      item = System::Group.new
      item.and :state , 'enabled'
      item.and :code, group.incoming_group_code
      system_group = item.find(:first, :order=>'start_at DESC')
      next if system_group.blank?

      update_field="section_sort=#{system_group.sort_no}"
      sql_where = "section_code='#{group.incoming_group_code}'"
      Gwmonitor::Control.where(:section_code=>group.incoming_group_code).update_all(:section_sort=>system_group.sort_no)
    end
    p "renew_controls_section_code 終了:#{Time.now}."
  end

  def self.renew_docs_section_code
    p "renew_docs_section_code 開始:#{Time.now}."

    doc_item = Gwmonitor::Doc
    sql  = 'SELECT section_code FROM gwmonitor_docs GROUP BY section_code ORDER BY section_code'
    docs = doc_item.find_by_sql(sql)
    for doc in docs
      next if doc.section_code.blank?

      group = Gwboard::RenewalGroup.where("present_group_code = ? and start_date = ?", doc.section_code,@start_date).first
      next if group.blank?

      update_fields = "section_code='#{group.incoming_group_code}', section_name='#{group.incoming_group_code}#{group.incoming_group_name}'"
      doc_item.where(:id => doc.id ,:section_code=>doc.section_code).update_all(:section_code=>group.incoming_group_code, :section_name => %Q(#{group.incoming_group_code}#{group.incoming_group_name}))
      p %Q[#{doc.section_code}, "#{update_fields}", #{Time.now}.]

      item = System::Group.new
      item.and :state , 'enabled'
      item.and :code, group.incoming_group_code
      system_group = item.find(:first, :order=>'start_at DESC')
      next if system_group.blank?

      l2_group_code = ''
      l2_group_code = system_group.parent.code unless system_group.parent.blank?

      update_field="l2_section_code='#{l2_group_code}', section_sort=#{system_group.sort_no}"
      sql_where = "section_code='#{group.incoming_group_code}'"
      doc_item.where(:id => doc.id ,:section_code => group.incoming_group_code).update_all(:l2_section_code= => l2_group_code, :section_sort => system_group.sort_no)

      p %Q[#{group.incoming_group_code}, "#{update_field}", #{Time.now}.]
    end
    p "renew_docs_section_code 終了:#{Time.now}."
  end

end
