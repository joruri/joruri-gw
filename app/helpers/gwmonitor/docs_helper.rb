# -*- encoding: utf-8 -*-
module Gwmonitor::DocsHelper

  def gwmonitor_attachments_form(form, item)
    form_id = '' if form_id.blank?
    return render(:partial => 'gwmonitor/admin/tool/attachments/form', :locals => {:f => form, :item => item})
  end

  def disp_expiry_date(expiry_date,item)
    ret = ''
    unless expiry_date.blank?
      ret = expiry_date.strftime('%Y-%m-%d %H:%M').to_s
      red_set = false
      red_set = true if expiry_date < Time.now
      red_set = true if item.state == 'closed' unless item.blank?
      ret = %Q[<span style="color:red">#{ret}</span>] if red_set
    end
    return ret
  end

  def is_gwmonitor_admin?
    ret = false
    ret = true if System::Model::Role.get(1, Site.user.id ,'gwmonitor', 'admin')
    ret = true if System::Model::Role.get(2, Site.user_group.id ,'gwmonitor', 'admin') unless ret
    return ret
  end

  def gwmonitor_settings
    ret = %Q[<span class="btSet"><a href="/gwmonitor/custom_groups">設定</a></span>]
    ret = %Q[<span class="btSetAdd"><a href="/gwmonitor/settings">管理者</a></span>] if is_gwmonitor_admin?
    return ret
  end

  def gwmonitor_base_attachments_form(form, item)
    form_id = '' if form_id.blank?
    return render(:partial => 'gwmonitor/admin/tool/base_attachments/form', :locals => {:f => form, :item => item})
  end

  def monitor_readers_table(title, objects, col, s_class, width)
    ret = ''
    ret += %Q[<table class="#{s_class}">]
    ret += %Q[<tr><th colspan="#{col}">#{title}</th></tr>]
    i=0
    s_table = ''
    for object in objects
      if col <= i
        i = 0
        s_table += '</tr>'
      end
      s_table += '<tr>' if i == 0
      s_table += %Q[<td style="width: #{width};">#{object[2]}&nbsp;</td>]
      i += 1
    end
    unless i == 0
      j = col - i
      for i in 1..j
        s_table += %Q[<td style="width: #{width};"></td>]
      end
      s_table += '</tr>'
    end
    ret += s_table
    ret += '</table>'
    return ret
  end

end
