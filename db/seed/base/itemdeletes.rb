# encoding: utf-8
## year fiscal
puts "Import itemdelete settings"


Gwbbs::Itemdelete.create({content_id: 0, admin_code: 'admin', limit_date: '24.months'})
Gwcircular::Itemdelete.create({content_id: 0, admin_code: 'admin', limit_date: '24.months'})
Gwmonitor::Itemdelete.create({content_id: 0, admin_code: 'admin', limit_date: '24.months'})
Questionnaire::Itemdelete.create({content_id: 0, admin_code: 'admin', limit_date: '24.months'})