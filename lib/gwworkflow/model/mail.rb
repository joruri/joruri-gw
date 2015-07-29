#encoding:utf-8
class Gwworkflow::Model::Mail
  
  def initialize
    system_settings = Gw::NameValue.get('yaml', nil, "gw_workflow_settings_system_default")
    @sender = nz(system_settings[:admin_email_from],"admin@127.0.0.1")
  end

  def send_commission_request_to_next_committee(doc, url)
    return unless cc = doc.current_step
    return unless cid = cc.committee.user_id
    return unless next_committee = System::User.find(cid)
    return unless should_send?(next_committee.id)
    return unless mail_to = next_committee.email
    title = "「#{doc.title}」の承認依頼"
    body = "#{Site.user.name}さんから「#{doc.title}」の承認依頼を受け取りました。\r\n"
    body += "下記のURLにアクセスして内容を確認し、承認してください。\r\n"
    body += "#{url}"
    dump "to:#{mail_to}, title:#{title}, body:#{body}"
    Gw.send_mail(@sender, mail_to, title, body)
  end

  def send_notice_of_accepted(doc, url)
    return unless creator = System::User.find(doc.creater_id)
    return unless should_send?(creator.id)
    return unless mail_to = creator.email
    title = "「#{doc.title}」が決裁されました"
    body = "「#{doc.title}」が決裁されました。\r\n"
    body += "下記のURLにアクセスして内容を確認してください。\r\n"
    body += "#{url}\r"
    dump "to:#{mail_to}, title:#{title}, body:#{body}"
    Gw.send_mail(@sender, mail_to, title, body)
  end
  
  def send_notice_of_rejected(doc, url)
    return unless creator = System::User.find(doc.creater_id)
    return unless mail_to = creator.email
    return unless should_send?(creator.id)
    return unless cc = doc.sorted_steps.last.committee.comment
    title = "「#{doc.title}」が却下されました"
    body = "「#{doc.title}」が却下されました。\r\n"
    body += "下記のURLにアクセスして内容を確認してください。\r\n"
    body += "#{url}\r"
    unless cc.blank?
      body += "\r\n承認者からのコメント：\r\n"
      body += "　#{cc}\r\n"
    end
    dump "to:#{mail_to}, title:#{title}, body:#{body}"
    Gw.send_mail(@sender, mail_to, title, body)
  end
  
  def should_send?(uid)
    setting = Gwworkflow::Setting.where(:unid => uid).first
    @notifying =  setting ? setting.notifying : false
  end
end