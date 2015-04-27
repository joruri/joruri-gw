class Gwmonitor::Mailer < DefaultMailer

  def request_mail(options = {from: '', to: '', subject: '', from_user: nil, doc: nil})
    @doc = options[:doc]
    @from_user = options[:from_user]
    mail from: options[:from], to: options[:to], subject: options[:subject]
  end
end
