class Gwworkflow::Model::Mail
  
  def initialize
    @sender = AppConfig.gwworkflow.workflow_settings[:admin_email_from].presence || "admin@localhost.localdomain"
  end

  def send_commission_request_to_next_committee(doc, url)
    return unless cc = doc.current_step
    return unless cid = cc.committee.user_id
    return unless next_committee = System::User.find(cid)
    return unless should_send?(next_committee.id)
    return unless mail_to = next_committee.email

    Gwworkflow::Mailer.commission_mail(from: @sender, to: mail_to, 
      subject: "「#{doc.title}」の承認依頼", doc: doc, url: url).deliver
  end

  def send_notice_of_accepted(doc, url)
    return unless creator = System::User.find(doc.creater_id)
    return unless should_send?(creator.id)
    return unless mail_to = creator.email

    Gwworkflow::Mailer.accept_mail(from: @sender, to: mail_to, 
      subject: "「#{doc.title}」が決裁されました", doc: doc, url: url).deliver
  end

  def send_notice_of_rejected(doc, url)
    return unless creator = System::User.find(doc.creater_id)
    return unless mail_to = creator.email
    return unless should_send?(creator.id)
    return unless cc = doc.sorted_steps.last.committee.comment

    Gwworkflow::Mailer.reject_mail(from: @sender, to: mail_to, 
      subject: "「#{doc.title}」が却下されました", doc: doc, url: url, cc: cc).deliver
  end

  def should_send?(uid)
    setting = Gwworkflow::Setting.where(:unid => uid).first
    @notifying =  setting ? setting.notifying : false
  end
end
