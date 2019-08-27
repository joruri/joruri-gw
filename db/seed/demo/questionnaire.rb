# encoding: utf-8
## attendance
puts "Import questionnaire demo"

user  = System::User.find_by(code: 'admin')
group = user.groups.first

base = Questionnaire::Base.create({
  state: 'draft',
  section_code: group.code,
  enquete_division: 1,
  admin_setting: 1,
  manage_title: '人権意識向上研修アンケート',
  title: '人権意識向上研修アンケート',
  expiry_date: Time.now + 3.months,
  able_date: Time.now,
  result_open_state: false,
  include_index: true
})
base.save

def create_field(base, sort_no, title, question_type, required_entry, _options, group_code, group_name)

  field = Questionnaire::FormField.new({
      state: 'public',
      question_type: question_type,
      sort_no: sort_no,
      required_entry: required_entry,
      title: title,
      field_cols: 60,
      field_rows: 3,
      group_repeat: 3,
      group_code: group_code,
      group_name: group_name,
      parent_id: base.id,
      auto_number_state: false
    })

  if _options.present?
    filed_options = []
    _options.each_with_index{|o, i| filed_options << Questionnaire::FieldOption.new({state: 'public', title: o, value: i})}
    field.options = filed_options
  end
   field._skip_logic = false
   field.save
end

create_field base, 10, "先日実施した人権意識向上研修についてのアンケートです。 \n回答内容は次回以降開催する研修の参考とさせていただきます。\n ご協力よろしくお願いします。", "display", 0, [], nil, nil

options = ['はい', 'どちらとも言えない', 'いいえ']

create_field base, 20, "【問− 1】研修内容は参考になりましたか。", "radio", 1, options, nil, nil
create_field base, 30, "【問− 2】講師の説明はわかりやすかったですか。", "radio", 1, options, nil, nil

create_field base, 40, "【問−3】【問−2】に関するコメント", "textarea", 0, [], nil, nil
create_field base, 50, "【問−4】ご意見・ご感想", "textarea", 0, [], nil, nil

create_field base, 60, "【問−5】「人権意識向上研修」以外に受講した研修を3つまで回答してください。", "group", 0, [], 1, 'group_field'
create_field base, 70, "研修名", "text", 0, [], 1, 'group_field'

base.update_columns(state: 'public')