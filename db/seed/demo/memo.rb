# encoding: utf-8
## memo
puts "Import memo demo"

u1 = System::User.where(code: 'user1').first
u2 = System::User.where(code: 'user2').first

memo = Gw::Memo.new({
  ed_at: Time.now - 10.minutes,
  fr_group: '○○○○○社 ',
  fr_user: '△△ ',
  title: '電話があったことをお伝えします。',
  body: '',
  selected_receiver_uids: [u1.id],
  uid: u2.id,
  ucode: u2.code,
  uname: u2.name
})
memo.set_tmp_id
memo.renew_attach_files = false
memo.save