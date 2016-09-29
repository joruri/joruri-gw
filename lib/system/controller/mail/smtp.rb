class System::Controller::Mail::Smtp < DefaultMailer
  def default_mail(mail_fr, mail_to, subject, message)
    mail({
      :from    => mail_fr,
      :to      => mail_to,
      :subject => subject,
      :body    => message
    })
  end
end