class Gwworkflow::Mailer < DefaultMailer

  def commission_mail(options = {from: '', to: '', subject: '', doc: nil, url: nil})
    @doc = options[:doc]
    @url = options[:url]
    mail from: options[:from], to: options[:to], subject: options[:subject]
  end

  def accept_mail(options = {from: '', to: '', subject: '', doc: nil, url: nil})
    @doc = options[:doc]
    @url = options[:url]
    mail from: options[:from], to: options[:to], subject: options[:subject]
  end

  def reject_mail(options = {from: '', to: '', subject: '', doc: nil, url: nil, cc: nil})
    @doc = options[:doc]
    @url = options[:url]
    @cc = options[:cc]
    mail from: options[:from], to: options[:to], subject: options[:subject]
  end
end
