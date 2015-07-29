#encoding:utf-8

module Gwcircular::GwcircularHelper
  def system_name
    return 'gwcircular'
  end

  def item_home_path
    return "/#{system_name}/"
  end

  def file_base_path
    return "/_attaches/#{system_name}"
  end
  
  def current_path
    return gwcircular_menus_path
  end

 	def public_uri(item)
    name = item.name
    content.public_uri + name + '/'
  end

  def public_path(item)
    name = item.name
    if name =~ /^[0-9]{8}$/
      _name = name
    else
      _name = File.join(name[0..0], name[0..1], name[0..2], name)
    end
    Site.public_path + content.public_uri + _name + '/index.html'
  end

  def item_path(item)
    return current_path
  end

  def show_path(item)
    if item.doc_type == 0
      return "#{current_path}/#{item.id}"
    else
      return "#{item_home_path}docs/#{item.id}"
    end
  end

  def csv_exports_path(item, condition)
    if item.doc_type == 0
      return "#{item_home_path}#{item.id}/csv_exports?cond=#{condition}"
    else
      return '#'
    end
  end

  def edit_path(item)
    return "#{item_home_path}#{item.id}/edit"
  end

  def doc_edit_path(item)
    return "#{item_home_path}docs/#{item.id}/edit"
  end

  def doc_state_already_update(item)
    return "#{item_home_path}docs/#{item.id}/already_update"
  end

  def clone_path(item)
    return "#{current_path}/#{item.id}/clone"
  end

  def delete_path(item)
    return "#{current_path}/#{item.id}"
  end

  def update_path(item)
    return "#{current_path}/#{item.id}"
  end

  def csv_export_file_path(item)
    if item.doc_type == 0
      return "#{current_path}/#{item.id}/csv_exports/export_csv"
    else
      return '#'
    end
  end

  def file_export_path(item)
    if item.doc_type == 0
      return "#{current_path}/#{item.id}/file_exports"
    else
      return '#'
    end
  end

  def status_name(item)
    str = ''
    if item.doc_type == 0
      str = '下書き' if item.state == 'draft'
      str = '配信済み' if item.state == 'public'
      str = '期限終了' if item.expiry_date < Time.now unless item.expiry_date.blank? if item.state == 'public'
    end
    if item.doc_type == 1
      str = '非通知' if item.state == 'preparation'
      str = '配信予定' if item.state == 'draft'
      str = '<div align="center"><span class="required">未読</span></div>' if item.state == 'unread'
      str = '<div align="center"><span class="notice">既読</span></div>' if item.state == 'already'
      str = '期限切れ' if item.expiry_date < Time.now unless item.expiry_date.blank? if item.state == 'public'
    end

    return str
  end
end
