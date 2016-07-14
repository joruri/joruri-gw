# encoding: utf-8
## digital library
puts "Import gwmonitor demo"

g1 = System::Group.where(code: '001001').first
g2 = System::Group.where(code: '001004').first


title1 = Gwmonitor::Control.create(
      state:  'preparation',
      section_code:  Core.user_group.code,
      send_change:  '1',
      spec_config:  3,
      able_date:  Time.now.strftime("%Y-%m-%d %H:%M"),
      expiry_date:  7.days.since.strftime("%Y-%m-%d %H:00"),
      upload_graphic_file_size_capacity:  100,
      upload_graphic_file_size_capacity_unit:  'MB',
      upload_document_file_size_capacity:  1,
      upload_document_file_size_capacity_unit:  'GB',
      upload_graphic_file_size_max:  50,
      upload_document_file_size_max:  500,
      upload_graphic_file_size_currently:  0,
      upload_document_file_size_currently:  0,
      reminder_start_section:  0,
      reminder_start_personal:  0,
      default_limit:  100,
      upload_system:  3,
      wiki:  0
    )

monitor_params1 = {
  title: '書庫に登録できるファイルについて',
  caption: '書庫に登録できるファイルには種類の制限および容量の制限がありますか。',
  state: 'public',
  admin_setting: 0,
  form_id: 1,
  reader_groups_json: %Q{[["", "#{g1.id}", "#{g1.name}"]]}
}

title1.attributes = monitor_params1
title1.able_date = Time.now
title1.upload_system = 3
title1.reminder_start_personal = 0

title1.save


title2 = Gwmonitor::Control.create(
      state:  'preparation',
      section_code:  Core.user_group.code,
      send_change:  '1',
      spec_config:  3,
      able_date:  Time.now.strftime("%Y-%m-%d %H:%M"),
      expiry_date:  7.days.since.strftime("%Y-%m-%d %H:00"),
      upload_graphic_file_size_capacity:  100,
      upload_graphic_file_size_capacity_unit:  'MB',
      upload_document_file_size_capacity:  1,
      upload_document_file_size_capacity_unit:  'GB',
      upload_graphic_file_size_max:  50,
      upload_document_file_size_max:  500,
      upload_graphic_file_size_currently:  0,
      upload_document_file_size_currently:  0,
      reminder_start_section:  3,
      reminder_start_personal:  0,
      default_limit:  100,
      upload_system:  3,
      wiki:  0
    )

monitor_params2 = {
  title: '  カスタムグループの利用方法について',
  caption: 'カスタムグループについて利用方法と注意点を教えてください。',
  state: 'public',
  admin_setting: 0,
  form_id: 1,
  reader_groups_json: %Q{[["", "#{g1.id}", "#{g1.name}"],["", "#{g2.id}", "#{g2.name}"]]}
}

title2.attributes = monitor_params2
title2.able_date = Time.now
title2.upload_system = 3
title2.reminder_start_personal = 0

title2.save
