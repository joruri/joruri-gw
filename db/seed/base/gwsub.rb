# encoding: utf-8
##gwsub
puts "Import gwsub module settings"

Gwsub::Capacityunitset.create({code_int: 1, code: 1, name: 'KB'})
Gwsub::Capacityunitset.create({code_int: 2, code: 2, name: 'MB'})
Gwsub::Capacityunitset.create({code_int: 3, code: 3, name: 'GB'})
Gwsub::Capacityunitset.create({code_int: 4, code: 4, name: 'TB'})

Gwsub::Externalmediakind.create({sort_order_int: 1, sort_order: 1, kind: 'CD', name: 'CD' })
Gwsub::Externalmediakind.create({sort_order_int: 2, sort_order: 2, kind: 'DVD', name: 'DVD' })
Gwsub::Externalmediakind.create({sort_order_int: 3, sort_order: 3, kind: 'BD' , name: 'BD' })
Gwsub::Externalmediakind.create({sort_order_int: 4, sort_order: 4, kind: 'FD' , name: 'FD' })
Gwsub::Externalmediakind.create({sort_order_int: 5, sort_order: 5, kind: 'HDD', name: 'HDD' })
Gwsub::Externalmediakind.create({sort_order_int: 6, sort_order: 6, kind: 'MO' , name: 'MO' })
Gwsub::Externalmediakind.create({sort_order_int: 7, sort_order: 7, kind: 'DAT', name: 'DAT' })
Gwsub::Externalmediakind.create({sort_order_int: 8, sort_order: 8, kind: 'USB', name: 'USB' })
Gwsub::Externalmediakind.create({sort_order_int: 9, sort_order: 9, kind: 'SD', name: 'SD' })
Gwsub::Externalmediakind.create({sort_order_int: 10, sort_order:  10, kind: 'SM' , name: 'SM' })
Gwsub::Externalmediakind.create({sort_order_int: 11, sort_order:  11, kind: 'CF' , name: 'CF' })

Gwsub::Sb04LimitSetting.create({type_name: 'stafflistview_limit', limit: 100})
Gwsub::Sb04LimitSetting.create({type_name: 'divideduties_limit', limit: 50})

Gwsub::Sb04Setting.create({name: 'network_telephone_url', type_name: 'url'})


Gwsub::Sb05MediaType.create({ media_code:1, media_name: '新聞', categories_code:1, categories_name: '原稿', max_size: nil , state: 1})
Gwsub::Sb05MediaType.create({ media_code:2, media_name: 'ラジオ', categories_code:1, categories_name: '原稿' , max_size: nil, state:1})
Gwsub::Sb05MediaType.create({ media_code:3, media_name: 'LED', categories_code:1, categories_name: '屋内', max_size: nil, state:2})
Gwsub::Sb05MediaType.create({ media_code:4, media_name: 'メルマガ', categories_code: 1, categories_name: '情報ＢＯＸ' , max_size: nil, state:1})
Gwsub::Sb05MediaType.create({ media_code:3, media_name: 'LED', categories_code:2, categories_name: '屋外' , max_size: nil,  state:2})
Gwsub::Sb05MediaType.create({ media_code:4, media_name: 'メルマガ', categories_code:2, categories_name: 'イベント情報', max_size: nil, state:1})


Gwsub::Sb06BudgetRole.create({code: 1, name: 'システム管理者'})
Gwsub::Sb06BudgetRole.create({code: 2, name: '財政課　更新'})
Gwsub::Sb06BudgetRole.create({code: 3, name: '財政課　照会'})
Gwsub::Sb06BudgetRole.create({code: 4, name: '主管課　更新'})
Gwsub::Sb06BudgetRole.create({code: 5, name: '主管課　照会'})
Gwsub::Sb06BudgetRole.create({code: 6, name: '原課　更新'})
Gwsub::Sb06BudgetRole.create({code: 7, name: '原課　照会'})

